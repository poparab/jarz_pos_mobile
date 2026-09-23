/// Wire models for the Task Board (`jarz_pos.api.tasks`).
///
/// Hand-written rather than Freezed, like the other recent feature modules:
/// the backend is Frappe, so a Check arrives as `0`/`1`, an Int can arrive as
/// a string through some query paths, and a missing value as `null`. Every
/// model tolerates all of those instead of trusting one shape.
library;

import 'dart:convert';

// ── Wire parsing ────────────────────────────────────────────────────────

int taskParseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value.toString().trim();
  if (text.isEmpty) return fallback;
  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? fallback;
}

double? taskParseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return double.tryParse(text);
}

bool taskParseBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return fallback;
  return text == '1' || text == 'true' || text == 'yes';
}

String taskParseString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? taskParseNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// A Frappe Date / Datetime string, or null. Frappe sends datetimes without a
/// zone in the site timezone, so they are parsed as local wall-clock time.
DateTime? taskParseDate(dynamic value) {
  final text = taskParseNullableString(value);
  if (text == null) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

Map<String, dynamic> taskAsMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> taskAsMapList(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

List<String> taskAsStringList(dynamic value) {
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}

/// `YYYY-MM-DD` for a date the API takes as a Frappe Date.
String taskFormatApiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

// ── Enums (raw API values; localized only at display) ───────────────────

abstract final class TaskStatus {
  static const toDo = 'To Do';
  static const inProgress = 'In Progress';
  static const inReview = 'In Review';
  static const done = 'Done';

  static const all = [toDo, inProgress, inReview, done];

  /// Moves that need a reason, mirroring the contract: sending a reviewed
  /// task back, and reopening a finished one. The board uses this because
  /// the card summary carries no permissions; the detail screen trusts the
  /// server's `needs_reason_for` instead.
  static bool needsReason(String from, String to) =>
      to == inProgress && (from == inReview || from == done);
}

abstract final class TaskPriority {
  static const normal = 'Normal';
  static const high = 'High';
  static const urgent = 'Urgent';

  static const all = [normal, high, urgent];
}

abstract final class TaskBoardView {
  static const all = 'all';
  static const mine = 'mine';
  static const created = 'created';
  static const review = 'review';

  static const values = [all, mine, created, review];

  static String normalize(String? value) =>
      values.contains(value) ? value! : all;
}

abstract final class TaskEntryKind {
  static const log = 'Log';
  static const comment = 'Comment';
  static const history = 'History';
}

// ── Models ──────────────────────────────────────────────────────────────

class TaskUserRef {
  final String user;
  final String fullName;
  final bool isManager;

  const TaskUserRef({
    required this.user,
    required this.fullName,
    this.isManager = false,
  });

  String get displayName => fullName.isNotEmpty ? fullName : user;

  factory TaskUserRef.fromJson(Map<String, dynamic> json) => TaskUserRef(
    user: taskParseString(json['user']),
    fullName: taskParseString(json['full_name']),
    isManager: taskParseBool(json['is_manager']),
  );
}

class TaskCardSummary {
  final String name;
  final String title;
  final String status;
  final String priority;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByName;
  final DateTime? dueDate;
  final bool isOverdue;
  final String? branch;
  final int subtasksTotal;
  final int subtasksDone;
  final int attachmentsCount;
  final int entriesCount;
  final bool archived;
  final DateTime? modified;
  final DateTime? submittedOn;
  final DateTime? completedOn;

  const TaskCardSummary({
    required this.name,
    required this.title,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    this.dueDate,
    this.isOverdue = false,
    this.branch,
    this.subtasksTotal = 0,
    this.subtasksDone = 0,
    this.attachmentsCount = 0,
    this.entriesCount = 0,
    this.archived = false,
    this.modified,
    this.submittedOn,
    this.completedOn,
  });

  String get assigneeDisplay =>
      assignedToName.isNotEmpty ? assignedToName : assignedTo;
  String get creatorDisplay =>
      createdByName.isNotEmpty ? createdByName : createdBy;

  factory TaskCardSummary.fromJson(Map<String, dynamic> json) =>
      TaskCardSummary(
        name: taskParseString(json['name']),
        title: taskParseString(json['title']),
        status: taskParseString(json['status'], fallback: TaskStatus.toDo),
        priority: taskParseString(
          json['priority'],
          fallback: TaskPriority.normal,
        ),
        assignedTo: taskParseString(json['assigned_to']),
        assignedToName: taskParseString(json['assigned_to_name']),
        createdBy: taskParseString(json['created_by']),
        createdByName: taskParseString(json['created_by_name']),
        dueDate: taskParseDate(json['due_date']),
        isOverdue: taskParseBool(json['is_overdue']),
        branch: taskParseNullableString(json['branch']),
        subtasksTotal: taskParseInt(json['subtasks_total']),
        subtasksDone: taskParseInt(json['subtasks_done']),
        attachmentsCount: taskParseInt(json['attachments_count']),
        entriesCount: taskParseInt(json['entries_count']),
        archived: taskParseBool(json['archived']),
        modified: taskParseDate(json['modified']),
        submittedOn: taskParseDate(json['submitted_on']),
        completedOn: taskParseDate(json['completed_on']),
      );
}

/// The card summary plus the fields only `get_task` carries.
class TaskDetail {
  final TaskCardSummary summary;
  final String description;
  final DateTime? startedOn;
  final String? completedBy;
  final String? completedByName;
  final DateTime? archivedOn;
  final String? archivedBy;

  const TaskDetail({
    required this.summary,
    this.description = '',
    this.startedOn,
    this.completedBy,
    this.completedByName,
    this.archivedOn,
    this.archivedBy,
  });

  String get name => summary.name;
  String get title => summary.title;
  String get status => summary.status;

  factory TaskDetail.fromJson(Map<String, dynamic> json) => TaskDetail(
    summary: TaskCardSummary.fromJson(json),
    description: taskParseString(json['description']),
    startedOn: taskParseDate(json['started_on']),
    completedBy: taskParseNullableString(json['completed_by']),
    completedByName: taskParseNullableString(json['completed_by_name']),
    archivedOn: taskParseDate(json['archived_on']),
    archivedBy: taskParseNullableString(json['archived_by']),
  );
}

class TaskSubtask {
  final String id;
  final String title;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? dueDate;
  final bool isDone;
  final String? doneBy;
  final String? doneByName;
  final DateTime? doneOn;
  final String createdBy;
  final bool isOverdue;
  final bool canEdit;
  final bool canToggle;

  const TaskSubtask({
    required this.id,
    required this.title,
    this.assignedTo,
    this.assignedToName,
    this.dueDate,
    this.isDone = false,
    this.doneBy,
    this.doneByName,
    this.doneOn,
    this.createdBy = '',
    this.isOverdue = false,
    this.canEdit = false,
    this.canToggle = false,
  });

  String? get assigneeDisplay => assignedToName ?? assignedTo;

  factory TaskSubtask.fromJson(Map<String, dynamic> json) => TaskSubtask(
    id: taskParseString(json['id'] ?? json['name']),
    title: taskParseString(json['title']),
    assignedTo: taskParseNullableString(json['assigned_to']),
    assignedToName: taskParseNullableString(json['assigned_to_name']),
    dueDate: taskParseDate(json['due_date']),
    isDone: taskParseBool(json['is_done']),
    doneBy: taskParseNullableString(json['done_by']),
    doneByName: taskParseNullableString(json['done_by_name']),
    doneOn: taskParseDate(json['done_on']),
    createdBy: taskParseString(json['created_by']),
    isOverdue: taskParseBool(json['is_overdue']),
    canEdit: taskParseBool(json['can_edit']),
    canToggle: taskParseBool(json['can_toggle']),
  );
}

class TaskAttachment {
  final String name;
  final String fileName;
  final int fileSize;
  final String contentType;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime? creation;
  final bool isImage;
  final String? entry;
  final bool canRemove;

  const TaskAttachment({
    required this.name,
    required this.fileName,
    this.fileSize = 0,
    this.contentType = '',
    this.uploadedBy = '',
    this.uploadedByName = '',
    this.creation,
    this.isImage = false,
    this.entry,
    this.canRemove = false,
  });

  String get uploaderDisplay =>
      uploadedByName.isNotEmpty ? uploadedByName : uploadedBy;

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    final contentType = taskParseString(json['content_type']);
    return TaskAttachment(
      name: taskParseString(json['name']),
      fileName: taskParseString(json['file_name']),
      fileSize: taskParseInt(json['file_size']),
      contentType: contentType,
      uploadedBy: taskParseString(json['uploaded_by']),
      uploadedByName: taskParseString(json['uploaded_by_name']),
      creation: taskParseDate(json['creation']),
      // Trust the flag, but fall back to the content type if a shape
      // without it ever arrives.
      isImage: taskParseBool(
        json['is_image'],
        fallback: contentType.startsWith('image/'),
      ),
      entry: taskParseNullableString(json['entry']),
      canRemove: taskParseBool(json['can_remove']),
    );
  }
}

class TaskEntry {
  final String name;
  final String kind;
  final String content;
  final String? event;
  final String author;
  final String authorName;
  final DateTime? creation;
  final List<String> mentions;
  final List<TaskAttachment> attachments;

  const TaskEntry({
    required this.name,
    required this.kind,
    this.content = '',
    this.event,
    this.author = '',
    this.authorName = '',
    this.creation,
    this.mentions = const [],
    this.attachments = const [],
  });

  String get authorDisplay => authorName.isNotEmpty ? authorName : author;

  factory TaskEntry.fromJson(Map<String, dynamic> json) {
    // `mentions` is a JSON list on the wire, but the DocType stores it as a
    // JSON string, so a shape that forwards the raw column is tolerated too.
    var mentionsRaw = json['mentions'];
    if (mentionsRaw is String && mentionsRaw.trim().startsWith('[')) {
      try {
        mentionsRaw = jsonDecode(mentionsRaw);
      } on FormatException {
        mentionsRaw = const [];
      }
    }
    return TaskEntry(
      name: taskParseString(json['name']),
      kind: taskParseString(json['kind'], fallback: TaskEntryKind.log),
      content: taskParseString(json['content']),
      event: taskParseNullableString(json['event']),
      author: taskParseString(json['author']),
      authorName: taskParseString(json['author_name']),
      creation: taskParseDate(json['creation']),
      mentions: taskAsStringList(mentionsRaw),
      attachments: taskAsMapList(
        json['attachments'],
      ).map(TaskAttachment.fromJson).toList(),
    );
  }
}

class TaskPermissions {
  final bool canEdit;
  final bool canArchive;
  final bool canAddSubtask;
  final bool canAssignSubtaskToOthers;
  final bool canLog;
  final bool canComment;
  final bool canUpload;
  final List<String> allowedTransitions;
  final List<String> needsReasonFor;

  const TaskPermissions({
    this.canEdit = false,
    this.canArchive = false,
    this.canAddSubtask = false,
    this.canAssignSubtaskToOthers = false,
    this.canLog = false,
    this.canComment = false,
    this.canUpload = false,
    this.allowedTransitions = const [],
    this.needsReasonFor = const [],
  });

  static const none = TaskPermissions();

  bool needsReason(String status) => needsReasonFor.contains(status);

  factory TaskPermissions.fromJson(Map<String, dynamic> json) =>
      TaskPermissions(
        canEdit: taskParseBool(json['can_edit']),
        canArchive: taskParseBool(json['can_archive']),
        canAddSubtask: taskParseBool(json['can_add_subtask']),
        canAssignSubtaskToOthers: taskParseBool(
          json['can_assign_subtask_to_others'],
        ),
        canLog: taskParseBool(json['can_log']),
        canComment: taskParseBool(json['can_comment']),
        canUpload: taskParseBool(json['can_upload']),
        allowedTransitions: taskAsStringList(json['allowed_transitions']),
        needsReasonFor: taskAsStringList(json['needs_reason_for']),
      );
}

/// Everything `get_task` (and every task mutation) answers with.
class TaskBundle {
  final TaskDetail task;
  final List<TaskSubtask> subtasks;
  final List<TaskAttachment> attachments;
  final List<TaskEntry> entries;
  final List<TaskUserRef> mentionable;
  final TaskPermissions permissions;

  const TaskBundle({
    required this.task,
    this.subtasks = const [],
    this.attachments = const [],
    this.entries = const [],
    this.mentionable = const [],
    this.permissions = TaskPermissions.none,
  });

  List<TaskEntry> entriesOfKind(String kind) =>
      entries.where((e) => e.kind == kind).toList(growable: false);

  bool get hasOpenSubtasks => subtasks.any((s) => !s.isDone);

  factory TaskBundle.fromJson(Map<String, dynamic> json) => TaskBundle(
    task: TaskDetail.fromJson(taskAsMap(json['task'])),
    subtasks: taskAsMapList(json['subtasks']).map(TaskSubtask.fromJson).toList(),
    attachments: taskAsMapList(
      json['attachments'],
    ).map(TaskAttachment.fromJson).toList(),
    entries: taskAsMapList(json['entries']).map(TaskEntry.fromJson).toList(),
    mentionable: taskAsMapList(
      json['mentionable'],
    ).map(TaskUserRef.fromJson).toList(),
    permissions: TaskPermissions.fromJson(taskAsMap(json['permissions'])),
  );
}

class TaskBoardContext {
  final bool canAccess;
  final bool isManager;
  final bool canCreate;
  final bool canViewAll;
  final bool canViewOverview;
  final TaskUserRef? me;
  final List<TaskUserRef> users;
  final List<String> branches;
  final List<String> statuses;
  final List<String> priorities;

  const TaskBoardContext({
    required this.canAccess,
    this.isManager = false,
    this.canCreate = false,
    this.canViewAll = false,
    this.canViewOverview = false,
    this.me,
    this.users = const [],
    this.branches = const [],
    this.statuses = TaskStatus.all,
    this.priorities = TaskPriority.all,
  });

  static const denied = TaskBoardContext(canAccess: false);

  TaskUserRef? userFor(String? user) {
    if (user == null) return null;
    for (final u in users) {
      if (u.user == user) return u;
    }
    return null;
  }

  factory TaskBoardContext.fromJson(Map<String, dynamic> json) {
    final me = taskAsMap(json['me']);
    final statuses = taskAsStringList(json['statuses']);
    final priorities = taskAsStringList(json['priorities']);
    return TaskBoardContext(
      canAccess: taskParseBool(json['can_access']),
      isManager: taskParseBool(json['is_manager']),
      canCreate: taskParseBool(json['can_create']),
      canViewAll: taskParseBool(json['can_view_all']),
      canViewOverview: taskParseBool(json['can_view_overview']),
      me: me.isEmpty ? null : TaskUserRef.fromJson(me),
      users: taskAsMapList(json['users']).map(TaskUserRef.fromJson).toList(),
      branches: taskAsStringList(json['branches']),
      statuses: statuses.isEmpty ? TaskStatus.all : statuses,
      priorities: priorities.isEmpty ? TaskPriority.all : priorities,
    );
  }
}

class TaskBoard {
  final Map<String, List<TaskCardSummary>> columns;
  final Map<String, int> counts;

  const TaskBoard({required this.columns, this.counts = const {}});

  List<TaskCardSummary> column(String status) =>
      columns[status] ?? const <TaskCardSummary>[];

  /// The server's count when it sent one, else what the column holds (the
  /// Done column is windowed, so its count can be larger than its list).
  int countFor(String status) => counts[status] ?? column(status).length;

  factory TaskBoard.fromJson(Map<String, dynamic> json) {
    final rawColumns = taskAsMap(json['columns']);
    final rawCounts = taskAsMap(json['counts']);
    final columns = <String, List<TaskCardSummary>>{};
    for (final status in TaskStatus.all) {
      columns[status] = taskAsMapList(
        rawColumns[status],
      ).map(TaskCardSummary.fromJson).toList();
    }
    final counts = <String, int>{};
    rawCounts.forEach((key, value) => counts[key] = taskParseInt(value));
    return TaskBoard(columns: columns, counts: counts);
  }

  /// A copy with [card] moved to [status] — the optimistic board update while
  /// `set_status` is in flight.
  TaskBoard moveCard(String cardName, String status) {
    TaskCardSummary? moving;
    final next = <String, List<TaskCardSummary>>{};
    columns.forEach((key, cards) {
      next[key] = cards.where((c) => c.name != cardName).toList();
      for (final c in cards) {
        if (c.name == cardName) moving = c;
      }
    });
    if (moving == null) return this;
    final m = moving!;
    final moved = TaskCardSummary(
      name: m.name,
      title: m.title,
      status: status,
      priority: m.priority,
      assignedTo: m.assignedTo,
      assignedToName: m.assignedToName,
      createdBy: m.createdBy,
      createdByName: m.createdByName,
      dueDate: m.dueDate,
      isOverdue: status == TaskStatus.done ? false : m.isOverdue,
      branch: m.branch,
      subtasksTotal: m.subtasksTotal,
      subtasksDone: m.subtasksDone,
      attachmentsCount: m.attachmentsCount,
      entriesCount: m.entriesCount,
      archived: m.archived,
      modified: m.modified,
      submittedOn: m.submittedOn,
      completedOn: m.completedOn,
    );
    next[status] = [moved, ...?next[status]];
    final nextCounts = Map<String, int>.from(counts);
    if (nextCounts.containsKey(m.status)) {
      nextCounts[m.status] = (nextCounts[m.status]! - 1).clamp(0, 1 << 30);
    }
    if (nextCounts.containsKey(status)) {
      nextCounts[status] = nextCounts[status]! + 1;
    }
    return TaskBoard(columns: next, counts: nextCounts);
  }
}

class TaskOverviewPerson {
  final String user;
  final String fullName;
  final bool isManager;
  final int open;
  final int inProgress;
  final int inReview;
  final int overdue;
  final int doneInPeriod;
  final int doneOnTimeInPeriod;
  final double? onTimeRate;

  const TaskOverviewPerson({
    required this.user,
    required this.fullName,
    this.isManager = false,
    this.open = 0,
    this.inProgress = 0,
    this.inReview = 0,
    this.overdue = 0,
    this.doneInPeriod = 0,
    this.doneOnTimeInPeriod = 0,
    this.onTimeRate,
  });

  String get displayName => fullName.isNotEmpty ? fullName : user;

  factory TaskOverviewPerson.fromJson(Map<String, dynamic> json) =>
      TaskOverviewPerson(
        user: taskParseString(json['user']),
        fullName: taskParseString(json['full_name']),
        isManager: taskParseBool(json['is_manager']),
        open: taskParseInt(json['open']),
        inProgress: taskParseInt(json['in_progress']),
        inReview: taskParseInt(json['in_review']),
        overdue: taskParseInt(json['overdue']),
        doneInPeriod: taskParseInt(json['done_in_period']),
        doneOnTimeInPeriod: taskParseInt(json['done_on_time_in_period']),
        onTimeRate: taskParseNullableDouble(json['on_time_rate']),
      );
}

class TaskOverview {
  final int periodDays;
  final List<TaskOverviewPerson> people;
  final int totalOpen;
  final int totalOverdue;
  final int totalInReview;
  final int totalDoneInPeriod;

  const TaskOverview({
    required this.periodDays,
    this.people = const [],
    this.totalOpen = 0,
    this.totalOverdue = 0,
    this.totalInReview = 0,
    this.totalDoneInPeriod = 0,
  });

  factory TaskOverview.fromJson(Map<String, dynamic> json) {
    final totals = taskAsMap(json['totals']);
    return TaskOverview(
      periodDays: taskParseInt(json['period_days'], fallback: 30),
      people: taskAsMapList(
        json['people'],
      ).map(TaskOverviewPerson.fromJson).toList(),
      totalOpen: taskParseInt(totals['open']),
      totalOverdue: taskParseInt(totals['overdue']),
      totalInReview: taskParseInt(totals['in_review']),
      totalDoneInPeriod: taskParseInt(totals['done_in_period']),
    );
  }
}

class TaskCounts {
  final int assignedOpen;
  final int reviewWaiting;
  final int overdue;

  const TaskCounts({
    this.assignedOpen = 0,
    this.reviewWaiting = 0,
    this.overdue = 0,
  });

  factory TaskCounts.fromJson(Map<String, dynamic> json) => TaskCounts(
    assignedOpen: taskParseInt(json['assigned_open']),
    reviewWaiting: taskParseInt(json['review_waiting']),
    overdue: taskParseInt(json['overdue']),
  );
}

/// The board's filter, as the user set it. Sent to `get_board` verbatim.
class TaskBoardFilter {
  final String view;
  final String? assignedTo;
  final String? createdBy;
  final String? branch;
  final String? priority;
  final bool overdueOnly;
  final bool includeArchived;
  final String search;
  final int doneDays;

  const TaskBoardFilter({
    this.view = TaskBoardView.all,
    this.assignedTo,
    this.createdBy,
    this.branch,
    this.priority,
    this.overdueOnly = false,
    this.includeArchived = false,
    this.search = '',
    this.doneDays = 30,
  });

  /// How many of the sheet's filters are set, for the filter button badge.
  /// The view and search have their own controls and are not counted.
  int get activeCount =>
      (assignedTo != null ? 1 : 0) +
      (createdBy != null ? 1 : 0) +
      (branch != null ? 1 : 0) +
      (priority != null ? 1 : 0) +
      (overdueOnly ? 1 : 0) +
      (includeArchived ? 1 : 0) +
      (doneDays != 30 ? 1 : 0);

  TaskBoardFilter copyWith({
    String? view,
    String? assignedTo,
    bool clearAssignedTo = false,
    String? createdBy,
    bool clearCreatedBy = false,
    String? branch,
    bool clearBranch = false,
    String? priority,
    bool clearPriority = false,
    bool? overdueOnly,
    bool? includeArchived,
    String? search,
    int? doneDays,
  }) => TaskBoardFilter(
    view: view ?? this.view,
    assignedTo: clearAssignedTo ? null : (assignedTo ?? this.assignedTo),
    createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
    branch: clearBranch ? null : (branch ?? this.branch),
    priority: clearPriority ? null : (priority ?? this.priority),
    overdueOnly: overdueOnly ?? this.overdueOnly,
    includeArchived: includeArchived ?? this.includeArchived,
    search: search ?? this.search,
    doneDays: doneDays ?? this.doneDays,
  );

  /// Keep only the view and search; clear the sheet's filters.
  TaskBoardFilter cleared() => TaskBoardFilter(view: view, search: search);

  Map<String, dynamic> toParams() => {
    'view': view,
    if (assignedTo != null) 'assigned_to': assignedTo,
    if (createdBy != null) 'created_by': createdBy,
    if (branch != null) 'branch': branch,
    if (priority != null) 'priority': priority,
    'overdue_only': overdueOnly ? 1 : 0,
    'include_archived': includeArchived ? 1 : 0,
    if (search.trim().isNotEmpty) 'search': search.trim(),
    'done_days': doneDays,
  };
}

/// One subtask as typed into the create form, before the task exists.
class NewSubtaskDraft {
  final String title;
  final String? assignedTo;
  final DateTime? dueDate;

  const NewSubtaskDraft({required this.title, this.assignedTo, this.dueDate});

  Map<String, dynamic> toJson() => {
    'title': title,
    if (assignedTo != null) 'assigned_to': assignedTo,
    if (dueDate != null) 'due_date': taskFormatApiDate(dueDate!),
  };
}
