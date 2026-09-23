// The detail notifier's entry + attachment flow: files are uploaded against
// the entry name `add_entry` returns, and only fall back to guessing the new
// entry when an older server leaves it out. Plus the attachment rules the
// backend enforces that the client pre-checks.
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/tasks/data/tasks_repository.dart';
import 'package:jarz_pos/src/features/tasks/models/task_models.dart';
import 'package:jarz_pos/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:jarz_pos/src/features/tasks/presentation/widgets/task_attachments.dart';
import 'package:jarz_pos/src/features/tasks/state/tasks_providers.dart';

TaskBundle _bundleWith(List<Map<String, dynamic>> entries) =>
    TaskBundle.fromJson({
      'task': {'name': 'TASK-1', 'title': 'T', 'status': 'Done'},
      'entries': entries,
    });

class _Repo extends TasksRepository {
  _Repo({required this.returnedEntry}) : super(Dio());

  final String? returnedEntry;
  final List<String?> uploadedTo = [];

  @override
  Future<TaskBundle> fetchTask(String name) async => _bundleWith(const []);

  @override
  Future<({TaskBundle bundle, String? entry})> addEntry(
    String name, {
    required String kind,
    required String content,
    List<String> mentions = const [],
  }) async {
    final bundle = _bundleWith([
      {'name': 'guessed', 'kind': kind, 'author': 'me@x'},
    ]);
    return (bundle: bundle, entry: returnedEntry);
  }

  @override
  Future<TaskBundle> uploadAttachment(
    String name, {
    required String filename,
    required Uint8List bytes,
    String? entry,
  }) async {
    uploadedTo.add(entry);
    return _bundleWith(const []);
  }
}

Future<List<String?>> _postWithFile(String? returnedEntry) async {
  final repo = _Repo(returnedEntry: returnedEntry);
  final notifier = TaskDetailNotifier(repo, 'TASK-1', onChanged: () {});
  await notifier.load();
  await notifier.addEntry(
    kind: TaskEntryKind.comment,
    content: 'photo attached',
    files: [(filename: 'a.jpg', bytes: Uint8List.fromList([1]))],
    me: 'me@x',
  );
  notifier.dispose();
  return repo.uploadedTo;
}

void main() {
  group('addEntry attachments', () {
    test('should upload against the entry name the server returns', () async {
      expect(await _postWithFile('ENTRY-42'), ['ENTRY-42']);
    });

    test('should fall back to the new-entry diff when entry is absent',
        () async {
      expect(await _postWithFile(null), ['guessed']);
    });
  });

  group('blocked file types', () {
    test('should refuse every extension the server 403s', () {
      for (final name in const [
        'page.html',
        'page.HTM',
        'logo.svg',
        'feed.xml',
        'x.js',
        'x.mjs',
        'doc.xhtml',
      ]) {
        expect(isTaskFileTypeBlocked(name), isTrue, reason: name);
      }
    });

    test('should allow ordinary files and names without an extension', () {
      for (final name in const [
        'photo.jpg',
        'report.pdf',
        'sheet.xlsx',
        'svg-notes.txt',
        'README',
        'trailing.',
      ]) {
        expect(isTaskFileTypeBlocked(name), isFalse, reason: name);
      }
    });
  });

  group('taskEntryCanAttach', () {
    // A Done task: comments stay open, logs and card uploads close.
    const done = TaskPermissions(canComment: true);

    test('should let a comment on a Done task carry files', () {
      expect(taskEntryCanAttach(done, TaskEntryKind.comment), isTrue);
    });

    test('should not let a log carry files when logging is closed', () {
      expect(taskEntryCanAttach(done, TaskEntryKind.log), isFalse);
    });
  });
}
