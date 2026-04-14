// Contract tests for Kanban API endpoints.
//
// Verifies that the KanbanColumn model can deserialize the current
// kanban_columns.json fixture. Refresh with snapshot_updater.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';

void main() {
  const fixturesDir = 'test/contracts/fixtures';

  group('Kanban Contract — get_kanban_columns', () {
    test('fixture deserializes to List<KanbanColumn> without error', () {
      final raw = File('$fixturesDir/kanban_columns.json').readAsStringSync();
      // API returns {"success": true, "columns": [...]} — extract the list.
      final decoded = jsonDecode(raw);
      final List<dynamic> list;
      if (decoded is Map && decoded.containsKey('columns')) {
        list = decoded['columns'] as List;
      } else {
        list = decoded as List;
      }
      final columns = list
          .map((e) => KanbanColumn.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(columns, isNotEmpty,
          reason: 'At least one kanban column expected');
      for (final col in columns) {
        expect(col.id, isNotEmpty, reason: 'Column id must not be empty');
        expect(col.name, isNotEmpty, reason: 'Column name must not be empty');
        expect(col.color, isNotEmpty, reason: 'Column color must not be empty');
      }
    });
  });
}
