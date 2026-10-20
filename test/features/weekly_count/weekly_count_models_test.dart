// Parsing of the weekly-count wire shapes (jarz_pos.api.branch_weekly_count).
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_models.dart';

Map<String, dynamic> _branch(
  String profile, {
  String state = 'due',
  bool member = true,
  bool lastDay = false,
  bool missed = false,
  Map<String, dynamic>? count,
}) => {
  'pos_profile': profile,
  'warehouse': '$profile - J',
  'is_member': member,
  'state': state,
  'last_day': lastDay,
  'missed_last_week': missed,
  'count': count,
};

Map<String, dynamic> _status(List<Map<String, dynamic>> branches) => {
  'week_start': '2026-10-17',
  'due_date': '2026-10-23',
  'today': '2026-10-20',
  'days_left': 3,
  'is_approver': 1,
  'pending_approval_count': 2,
  'branches': branches,
};

void main() {
  group('state', () {
    test('parses every documented value', () {
      expect(WeeklyCountState.parse('due'), WeeklyCountState.due);
      expect(
        WeeklyCountState.parse('pending_approval'),
        WeeklyCountState.pendingApproval,
      );
      expect(WeeklyCountState.parse('done'), WeeklyCountState.done);
      expect(WeeklyCountState.parse('rejected'), WeeklyCountState.rejected);
      expect(WeeklyCountState.parse('later'), WeeklyCountState.unknown);
      expect(WeeklyCountState.parse(null), WeeklyCountState.unknown);
    });

    test('only due and rejected still need a count', () {
      expect(WeeklyCountState.due.needsCount, isTrue);
      expect(WeeklyCountState.rejected.needsCount, isTrue);
      expect(WeeklyCountState.pendingApproval.needsCount, isFalse);
      expect(WeeklyCountState.done.needsCount, isFalse);
      expect(WeeklyCountState.unknown.needsCount, isFalse);
    });
  });

  group('status', () {
    test('reads the header fields', () {
      final s = WeeklyCountStatus.fromJson(_status([]));
      expect(s.weekStart, '2026-10-17');
      expect(s.dueDate, '2026-10-23');
      expect(s.daysLeft, 3);
      expect(s.isApprover, isTrue);
      expect(s.pendingApprovalCount, 2);
      expect(s.canCount, isFalse);
      expect(s.hasDue, isFalse);
    });

    test('a null count block is no count yet', () {
      final s = WeeklyCountStatus.fromJson(_status([_branch('Maadi')]));
      expect(s.branches.single.count, isNull);
      expect(s.branches.single.state, WeeklyCountState.due);
    });

    test('reads the count block', () {
      final s = WeeklyCountStatus.fromJson(
        _status([
          _branch(
            'Maadi',
            state: 'rejected',
            count: {
              'name': 'BWC-0001',
              'status': 'Rejected',
              'counted_by': 'a@x.com',
              'counted_by_name': 'Ahmed',
              'counted_at': '2026-10-19 10:00:00',
              'rejection_reason': 'Recount the jars',
            },
          ),
        ]),
      );
      final ref = s.branches.single.count!;
      expect(ref.name, 'BWC-0001');
      expect(ref.status, WeeklyCountDocStatus.rejected);
      expect(ref.counterLabel, 'Ahmed');
      expect(ref.rejectionReason, 'Recount the jars');
    });

    test('only member branches that still owe a count raise the banner', () {
      final s = WeeklyCountStatus.fromJson(
        _status([
          _branch('Maadi'),
          _branch('Zayed', state: 'pending_approval'),
          _branch('Nasr City', member: false),
          _branch('Tagamoa', state: 'rejected'),
        ]),
      );
      expect(s.branches, hasLength(4));
      expect(s.memberBranches.map((b) => b.posProfile), [
        'Maadi',
        'Zayed',
        'Tagamoa',
      ]);
      expect(s.dueMemberBranches.map((b) => b.posProfile), [
        'Maadi',
        'Tagamoa',
      ]);
      expect(s.hasDue, isTrue);
      expect(s.hasRejected, isTrue);
      expect(s.canCount, isTrue);
      expect(s.branchNamed('Zayed')?.state, WeeklyCountState.pendingApproval);
      expect(s.branchNamed('Nowhere'), isNull);
    });

    test('a non-member branch that is due does not raise the banner', () {
      final s = WeeklyCountStatus.fromJson(
        _status([_branch('Nasr City', member: false)]),
      );
      expect(s.hasDue, isFalse);
      expect(s.canCount, isTrue);
    });

    test('urgent on the last day, after a missed week, or when rejected', () {
      bool urgentFor(Map<String, dynamic> b) =>
          WeeklyCountStatus.fromJson(_status([b])).urgent;
      expect(urgentFor(_branch('A')), isFalse);
      expect(urgentFor(_branch('A', lastDay: true)), isTrue);
      expect(urgentFor(_branch('A', missed: true)), isTrue);
      expect(urgentFor(_branch('A', state: 'rejected')), isTrue);
      // A non-member's last day is not this user's emergency.
      expect(urgentFor(_branch('A', lastDay: true, member: false)), isFalse);
    });

    test('drops a branch with no profile and survives a missing list', () {
      final s = WeeklyCountStatus.fromJson({
        ..._status([
          {'state': 'due'},
        ]),
      });
      expect(s.branches, isEmpty);
      final bare = WeeklyCountStatus.fromJson({'days_left': '2'});
      expect(bare.branches, isEmpty);
      expect(bare.daysLeft, 2);
      expect(bare.isApprover, isFalse);
    });
  });

  group('sheet', () {
    Map<String, dynamic> item(String code, [String? name]) => {
      'item_code': code,
      'item_name': name,
      'stock_uom': 'Nos',
      'image': null,
    };

    final json = {
      'pos_profile': 'Maadi',
      'warehouse': 'Maadi - J',
      'week_start': '2026-10-17',
      'due_date': '2026-10-23',
      'is_approver': false,
      'state': 'due',
      'count': null,
      'total_items': 4,
      'sections': [
        {
          'key': 'Large',
          'title': 'Large',
          'items': [item('L1', 'Large Lotus'), item('L2')],
        },
        {'key': 'Medium', 'title': 'Medium', 'items': <dynamic>[]},
        {
          'key': 'Small',
          'title': 'Small',
          'items': [item('S1', 'Small Lotus')],
        },
        {
          'key': 'Other',
          'title': 'Other',
          'items': [
            item('O1', 'Spoon'),
            {'item_code': '', 'item_name': 'blank'},
          ],
        },
      ],
    };

    test('keeps sections in server order and drops empty ones', () {
      final sheet = WeeklyCountSheet.fromJson(json);
      expect(sheet.sections.map((s) => s.key), ['Large', 'Small', 'Other']);
      expect(sheet.state, WeeklyCountState.due);
      expect(sheet.isApprover, isFalse);
      expect(sheet.count, isNull);
      expect(sheet.totalItems, 4);
    });

    test('lists every item code in sheet order', () {
      final sheet = WeeklyCountSheet.fromJson(json);
      expect(sheet.itemCodes, ['L1', 'L2', 'S1', 'O1']);
    });

    test('falls back to the code when the name is missing', () {
      final sheet = WeeklyCountSheet.fromJson(json);
      final l2 = sheet.allItems.firstWhere((i) => i.itemCode == 'L2');
      expect(l2.itemName, 'L2');
      expect(l2.stockUom, 'Nos');
    });

    test('derives total_items when the server leaves it out', () {
      final sheet = WeeklyCountSheet.fromJson({...json}..remove('total_items'));
      expect(sheet.totalItems, 4);
    });

    test('an item listed twice is counted once', () {
      final sheet = WeeklyCountSheet.fromJson({
        'pos_profile': 'Maadi',
        'week_start': '2026-10-17',
        'sections': [
          {
            'key': 'Large',
            'items': [item('A'), item('B')],
          },
          {
            'key': 'Small',
            'items': [item('B'), item('C')],
          },
        ],
      });
      expect(sheet.itemCodes, ['A', 'B', 'C']);
    });
  });

  group('submit, list and detail', () {
    test('submit result knows when stock already moved', () {
      final auto = WeeklyCountSubmitResult.fromJson({
        'ok': true,
        'name': 'BWC-1',
        'status': 'Approved',
        'auto_approved': true,
        'stock_reconciliation': 'MAT-RECO-1',
        'differences_count': 2,
        'total_items': 30,
      });
      expect(auto.posted, isTrue);
      expect(auto.differencesCount, 2);

      final pending = WeeklyCountSubmitResult.fromJson({
        'name': 'BWC-2',
        'status': 'Pending Approval',
        'auto_approved': false,
        'differences_count': null,
        'total_items': 30,
      });
      expect(pending.posted, isFalse);
      expect(pending.ok, isTrue);
      expect(pending.differencesCount, isNull);
    });

    test('a detail for a non-approver is blind', () {
      final d = WeeklyCountDetail.fromJson({
        'name': 'BWC-2',
        'pos_profile': 'Maadi',
        'status': 'Pending Approval',
        'can_approve': false,
        'lines': [
          {'item_code': 'A', 'counted_qty': 3, 'system_qty': null},
          {'item_code': 'B', 'counted_qty': 0, 'system_qty': null},
        ],
      });
      expect(d.canApprove, isFalse);
      expect(d.showsSystemQty, isFalse);
      expect(d.differenceLines, isEmpty);
      expect(d.header.isPending, isTrue);
      expect(d.header.totalItems, 2);
    });

    test('an approver sees which lines differ', () {
      final d = WeeklyCountDetail.fromJson({
        'name': 'BWC-2',
        'pos_profile': 'Maadi',
        'status': 'Pending Approval',
        'can_approve': 1,
        'total_items': 3,
        'differences_count': 2,
        'lines': [
          {
            'item_code': 'A',
            'counted_qty': 3,
            'system_qty': 5,
            'difference': -2,
          },
          {'item_code': 'B', 'counted_qty': 4, 'system_qty': 4},
          {'item_code': 'C', 'counted_qty': 1, 'system_qty': 0},
        ],
      });
      expect(d.canApprove, isTrue);
      expect(d.showsSystemQty, isTrue);
      expect(d.differenceLines.map((l) => l.itemCode), ['A', 'C']);
      expect(d.unchangedLines.map((l) => l.itemCode), ['B']);
      expect(d.lines.last.effectiveDifference, 1);
      expect(d.header.differencesCount, 2);
    });

    test('a list row reads its fields', () {
      final row = WeeklyCountSummary.fromJson({
        'name': 'BWC-3',
        'pos_profile': 'Zayed',
        'week_start': '2026-10-17',
        'status': 'Approved',
        'counted_by': 'b@x.com',
        'total_items': '12',
      });
      expect(row.isPending, isFalse);
      expect(row.counterLabel, 'b@x.com');
      expect(row.totalItems, 12);
      expect(row.differencesCount, isNull);
    });
  });
}
