// Branch access repository wire shape: which method each call hits, what body
// it sends, and that the contract's JSON parses - defensively - into models.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/branch_access/data/branch_access_repository.dart';
import 'package:jarz_pos/src/features/branch_access/models/branch_access_models.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Object? Function(RequestOptions options) respond = (_) => const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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

const _base = '/api/method/jarz_pos.api.branch_access';

const _overview = {
  'success': true,
  'can_manage_all': false,
  'branches': [
    {
      'pos_profile': 'Dokki',
      'shift_location': 'Dokki',
      'manageable': true,
      'open_shift': {
        'name': 'POS-OPE-2026-00100',
        'user': 'seif@example.com',
        'user_full_name': 'Seif',
        'since': '2026-09-23 12:47:10',
      },
    },
    {
      'pos_profile': 'Nasr city',
      'shift_location': 'Nasr City',
      'manageable': 1,
      'open_shift': null,
    },
    {'pos_profile': '6th of october', 'manageable': false},
  ],
  'users': [
    {
      'user': 'ali@example.com',
      'full_name': 'Ali',
      'employee': 'HR-EMP-0001',
      'employee_name': 'Ali Hassan',
      'enabled': 1,
      'is_self': false,
      'branches': ['Dokki', 'Nasr city'],
      'day_access': [
        {
          'name': 'JPDA-2026-00001',
          'pos_profile': 'Nasr city',
          'access_date': '2026-09-23',
          'status': 'Active',
          'expires_at': '2026-09-24 03:00:00',
          'row_added': 1,
        },
        {
          'name': 'JPDA-2026-00002',
          'pos_profile': '6th of october',
          'access_date': '2026-09-25',
          'status': 'Scheduled',
          'expires_at': '2026-09-26 03:00:00',
          'row_added': 0,
        },
      ],
    },
    // A user row missing most keys must still parse.
    {'user': 'bare@example.com'},
  ],
};

void main() {
  late _Adapter adapter;
  late BranchAccessRepository repository;

  setUp(() {
    adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    repository = BranchAccessRepository(dio);
  });

  group('getOverview', () {
    test('parses branches, open shifts and per-user access', () async {
      adapter.respond = (_) => _overview;
      final overview = await repository.getOverview();

      expect(adapter.requests.single.path, '$_base.get_branch_access');
      expect(overview.canManageAll, isFalse);
      expect(overview.branches.map((b) => b.posProfile), [
        'Dokki',
        'Nasr city',
        '6th of october',
      ]);

      final dokki = overview.branches[0];
      expect(dokki.isOpen, isTrue);
      expect(dokki.isEditable, isFalse);
      expect(dokki.openShift!.holder, 'Seif');
      expect(dokki.openShift!.sinceTime, DateTime(2026, 9, 23, 12, 47, 10));

      final nasr = overview.branches[1];
      expect(nasr.manageable, isTrue, reason: '1 reads as true');
      expect(nasr.isOpen, isFalse);
      expect(nasr.isEditable, isTrue);

      final october = overview.branches[2];
      expect(october.shiftLocation, isNull);
      expect(october.manageable, isFalse);

      final ali = overview.users.first;
      expect(ali.enabled, isTrue);
      expect(ali.employeeName, 'Ali Hassan');
      expect(ali.dayAccess, hasLength(2));
      expect(ali.stateOn('Dokki'), BranchMembershipState.member);
      // The Nasr City row is there only because today's grant added it.
      expect(ali.stateOn('Nasr city'), BranchMembershipState.dayAccessActive);
      expect(ali.isPermanentOn('Nasr city'), isFalse);
      expect(
        ali.stateOn('6th of october'),
        BranchMembershipState.dayAccessScheduled,
      );
      expect(ali.matches('hassan'), isTrue);
      expect(ali.matches('nobody'), isFalse);

      final bare = overview.users.last;
      expect(bare.displayName, 'bare@example.com');
      expect(bare.enabled, isTrue);
      expect(bare.branches, isEmpty);
      expect(bare.stateOn('Dokki'), BranchMembershipState.none);
      // No `editable` key: fall back to the own-row rule.
      expect(bare.editable, isNull);
      expect(bare.isLockedFor(canManageAll: false), isFalse);
    });

    test('editable is parsed and wins over is_self', () {
      final locked = BranchAccessUser.fromJson({
        'user': 'lm@example.com',
        'editable': 0,
      });
      expect(locked.editable, isFalse);
      expect(locked.isLockedFor(canManageAll: true), isTrue);

      final selfOld = BranchAccessUser.fromJson({
        'user': 'me@example.com',
        'is_self': true,
      });
      expect(selfOld.isLockedFor(canManageAll: false), isTrue);
      expect(selfOld.isLockedFor(canManageAll: true), isFalse);
    });

    test('a day access that did not add the row keeps the member state', () {
      final user = BranchAccessUser.fromJson({
        'user': 'u@example.com',
        'full_name': 'U',
        'branches': ['Dokki'],
        'day_access': [
          {
            'name': 'JPDA-1',
            'pos_profile': 'Dokki',
            'access_date': '2026-09-23',
            'status': 'Active',
            'row_added': 0,
          },
        ],
      });
      expect(user.stateOn('Dokki'), BranchMembershipState.member);
    });
  });

  test('setBranchAccess sends 0/1 and parses changed', () async {
    adapter.respond = (_) => {
      'success': true,
      'changed': false,
      'user': 'ali@example.com',
      'pos_profile': 'Dokki',
      'allowed': 0,
      'log': null,
    };
    final result = await repository.setBranchAccess(
      user: 'ali@example.com',
      posProfile: 'Dokki',
      allowed: false,
      notes: '  ',
    );
    final request = adapter.requests.single;
    expect(request.path, '$_base.set_branch_access');
    expect(request.data, {
      'user': 'ali@example.com',
      'pos_profile': 'Dokki',
      'allowed': 0,
    });
    expect(result.changed, isFalse);
    expect(result.allowed, isFalse);
  });

  test(
    'grantDayAccess sends the ISO date and returns the server message',
    () async {
      adapter.respond = (_) => {
        'success': true,
        'day_access': {
          'name': 'JPDA-2026-00003',
          'status': 'Scheduled',
          'access_date': '2026-09-25',
          'starts_at': '2026-09-25 00:00:00',
          'expires_at': '2026-09-26 03:00:00',
          'row_added': 0,
        },
        'message': 'Scheduled for 2026-09-25.',
      };
      final result = await repository.grantDayAccess(
        user: 'ali@example.com',
        posProfile: 'Dokki',
        accessDate: '2026-09-25',
        notes: 'Covering Seif',
      );
      final request = adapter.requests.single;
      expect(request.path, '$_base.grant_day_access');
      expect(request.data, {
        'user': 'ali@example.com',
        'pos_profile': 'Dokki',
        'access_date': '2026-09-25',
        'notes': 'Covering Seif',
      });
      expect(result.dayAccess!.isScheduled, isTrue);
      expect(result.dayAccess!.startsAt, '2026-09-25 00:00:00');
      expect(result.message, 'Scheduled for 2026-09-25.');
    },
  );

  test('cancelDayAccess posts the grant name', () async {
    adapter.respond = (_) => {
      'success': true,
      'day_access': {'name': 'JPDA-1', 'status': 'Cancelled'},
    };
    final result = await repository.cancelDayAccess('JPDA-1');
    expect(adapter.requests.single.path, '$_base.cancel_day_access');
    expect(adapter.requests.single.data, {'name': 'JPDA-1'});
    expect(result.dayAccess!.status, 'Cancelled');
    expect(result.message, isNull);
  });

  test('getAccessLog pages and filters', () async {
    adapter.respond = (_) => {
      'success': true,
      'rows': [
        {
          'name': 'JBAL-2026-00001',
          'creation': '2026-09-23 13:00:00',
          'user': 'ali@example.com',
          'user_full_name': 'Ali',
          'employee_name': 'Ali Hassan',
          'pos_profile': 'Dokki',
          'action': 'Day Access Started',
          'source': 'Scheduler',
          'notes': null,
          'changed_by': 'Administrator',
          'changed_by_name': null,
          'day_access': 'JPDA-1',
        },
      ],
      'has_more': true,
    };
    final page = await repository.getAccessLog(
      posProfile: 'Dokki',
      limit: 50,
      start: 50,
    );
    final request = adapter.requests.single;
    expect(request.path, '$_base.get_access_log');
    expect(request.data, {'pos_profile': 'Dokki', 'limit': 50, 'start': 50});
    expect(page.hasMore, isTrue);
    final row = page.rows.single;
    expect(row.subjectName, 'Ali');
    expect(row.actorName, 'Administrator');
    expect(row.notes, isNull);
    expect(row.creationTime, DateTime(2026, 9, 23, 13));
  });
}
