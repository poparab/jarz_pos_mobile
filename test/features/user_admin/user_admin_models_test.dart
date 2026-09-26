// User management models: the contract's JSON parses - defensively - and the
// list filters behave.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/user_admin/models/user_admin_models.dart';
import 'package:jarz_pos/src/features/user_admin/state/user_admin_providers.dart';

const _fullUser = {
  'name': 'ali@example.com',
  'email': 'ali@example.com',
  'full_name': 'Ali Hassan',
  'first_name': 'Ali',
  'last_name': 'Hassan',
  'mobile_no': '01000000000',
  'enabled': 1,
  'require_pos_shift': 1,
  'last_login': '2026-09-25 10:15:00.123456',
  'last_active': '2026-09-25 11:00:00',
  'creation': '2026-01-02 09:00:00',
  'role_profiles': ['Jarz Line Manager', 'Jarz Cashier'],
  'roles': ['JARZ Line Manager', 'POS User'],
  'tier': 'line_manager',
  'branches': ['Dokki', 'Nasr city'],
  'employee': 'HR-EMP-0001',
  'employee_name': 'Ali Hassan',
  'employee_branch': 'Dokki',
  'is_privileged': false,
  'is_self': 0,
  'can_edit': true,
};

void main() {
  group('UserAdminContext', () {
    test('parses flags, password rule and profiles', () {
      final ctx = UserAdminContext.fromJson({
        'can_manage': true,
        'is_system_manager': 0,
        'min_password_length': 10,
        'role_profiles': [
          {
            'name': 'Jarz Manager',
            'roles': ['JARZ Manager'],
            'tier': 'manager',
            'privileged': true,
            'assignable': false,
          },
          {
            'name': 'Jarz Cashier',
            'roles': ['POS User', 'Sales User'],
            'tier': 'staff',
            'privileged': 0,
            'assignable': 1,
          },
          // Nameless rows are dropped.
          {'roles': []},
          'not a map',
        ],
      });
      expect(ctx.canManage, isTrue);
      expect(ctx.isSystemManager, isFalse);
      expect(ctx.minPasswordLength, 10);
      expect(ctx.roleProfiles.map((p) => p.name), [
        'Jarz Manager',
        'Jarz Cashier',
      ]);
      final manager = ctx.profile('Jarz Manager')!;
      expect(manager.tier, UserTier.manager);
      expect(manager.privileged, isTrue);
      expect(manager.assignable, isFalse);
      final cashier = ctx.profile('Jarz Cashier')!;
      expect(cashier.roles, ['POS User', 'Sales User']);
      expect(cashier.assignable, isTrue);
      expect(ctx.profile('Nope'), isNull);
    });

    test('an empty body is a locked, sensible default', () {
      final ctx = UserAdminContext.fromJson({});
      expect(ctx.canManage, isFalse);
      expect(ctx.minPasswordLength, 8);
      expect(ctx.roleProfiles, isEmpty);
    });
  });

  group('UserAdminUser', () {
    test('parses every field of the contract', () {
      final u = UserAdminUser.fromJson(Map<String, dynamic>.from(_fullUser));
      expect(u.name, 'ali@example.com');
      expect(u.displayName, 'Ali Hassan');
      expect(u.firstName, 'Ali');
      expect(u.lastName, 'Hassan');
      expect(u.mobileNo, '01000000000');
      expect(u.enabled, isTrue);
      expect(u.requirePosShift, isTrue);
      expect(u.lastLoginTime, isNotNull);
      expect(u.lastLoginTime!.year, 2026);
      expect(u.creationTime, DateTime(2026, 1, 2, 9));
      expect(u.roleProfiles, ['Jarz Line Manager', 'Jarz Cashier']);
      expect(u.roles, contains('POS User'));
      expect(u.tier, UserTier.lineManager);
      expect(u.branches, ['Dokki', 'Nasr city']);
      expect(u.employee, 'HR-EMP-0001');
      expect(u.employeeBranch, 'Dokki');
      expect(u.isPrivileged, isFalse);
      expect(u.isSelf, isFalse);
      expect(u.canEdit, isTrue);
      expect(u.initials, 'AH');
    });

    test('a bare row still parses, view-only by default', () {
      final u = UserAdminUser.fromJson({'name': 'bare@example.com'});
      expect(u.displayName, 'bare@example.com');
      expect(u.enabled, isTrue);
      expect(u.canEdit, isFalse);
      expect(u.tier, UserTier.other);
      expect(u.roleProfiles, isEmpty);
      expect(u.branches, isEmpty);
      expect(u.lastLoginTime, isNull);
      expect(u.initials, 'BA');
    });

    test('0/"0"/null flags read as false; unknown tier is other', () {
      final u = UserAdminUser.fromJson({
        'name': 'x@example.com',
        'enabled': '0',
        'is_self': null,
        'can_edit': 0,
        'tier': 'astronaut',
        'full_name': '   ',
        'role_profiles': ['A', null, ' '],
      });
      expect(u.enabled, isFalse);
      expect(u.isSelf, isFalse);
      expect(u.canEdit, isFalse);
      expect(u.tier, UserTier.other);
      expect(u.fullName, isNull);
      expect(u.roleProfiles, ['A']);
    });

    test('copyWithEnabled changes only enabled', () {
      final u = UserAdminUser.fromJson(Map<String, dynamic>.from(_fullUser));
      final off = u.copyWithEnabled(false);
      expect(off.enabled, isFalse);
      expect(off.roleProfiles, u.roleProfiles);
      expect(off.employee, u.employee);
      expect(off.canEdit, u.canEdit);
    });

    test('matches on name, email, mobile, employee and profile', () {
      final u = UserAdminUser.fromJson(Map<String, dynamic>.from(_fullUser));
      expect(u.matches(''), isTrue);
      expect(u.matches('hassan'), isTrue);
      expect(u.matches('0100'), isTrue);
      expect(u.matches('emp-0001'), isTrue);
      expect(u.matches('cashier'), isTrue);
      expect(u.matches('nobody'), isFalse);
    });
  });

  test('UserTier.parse maps every wire value', () {
    for (final tier in UserTier.values) {
      expect(UserTier.parse(tier.wire), tier);
    }
    expect(UserTier.parse('LINE_MANAGER'), UserTier.lineManager);
    expect(UserTier.parse(null), UserTier.other);
  });

  test('UserAdminEmployee.linkedElsewhere', () {
    final free = UserAdminEmployee.fromJson({
      'name': 'HR-EMP-1',
      'employee_name': 'Mona',
      'branch': 'Dokki',
      'user_id': null,
    });
    expect(free.displayName, 'Mona');
    expect(free.linkedElsewhere('a@example.com'), isFalse);
    expect(free.linkedElsewhere(null), isFalse);

    final taken = UserAdminEmployee.fromJson({
      'name': 'HR-EMP-2',
      'user_id': 'b@example.com',
    });
    expect(taken.displayName, 'HR-EMP-2');
    expect(taken.linkedElsewhere('a@example.com'), isTrue);
    expect(taken.linkedElsewhere('b@example.com'), isFalse);
    // Creating a new account: any link is someone else's.
    expect(taken.linkedElsewhere(null), isTrue);
  });

  test('UserAdminAck reads ok and user/deleted', () {
    final reset = UserAdminAck.fromJson({'ok': 1, 'user': 'a@example.com'});
    expect(reset.ok, isTrue);
    expect(reset.user, 'a@example.com');
    final deleted = UserAdminAck.fromJson({
      'ok': true,
      'deleted': 'b@example.com',
    });
    expect(deleted.user, 'b@example.com');
  });

  group('filterUsers', () {
    final users = [
      UserAdminUser.fromJson(Map<String, dynamic>.from(_fullUser)),
      UserAdminUser.fromJson({
        'name': 'sara@example.com',
        'full_name': 'Sara',
        'enabled': 0,
        'tier': 'staff',
      }),
      UserAdminUser.fromJson({
        'name': 'boss@example.com',
        'full_name': 'Boss',
        'enabled': 1,
        'tier': 'manager',
      }),
    ];

    test('status', () {
      expect(filterUsers(users), hasLength(3));
      expect(
        filterUsers(users, status: UserStatusFilter.active).map((u) => u.name),
        ['ali@example.com', 'boss@example.com'],
      );
      expect(
        filterUsers(
          users,
          status: UserStatusFilter.disabled,
        ).map((u) => u.name),
        ['sara@example.com'],
      );
    });

    test('tier and query combine', () {
      expect(filterUsers(users, tier: UserTier.manager).map((u) => u.name), [
        'boss@example.com',
      ]);
      expect(filterUsers(users, tier: UserTier.manager, query: 'ali'), isEmpty);
      expect(filterUsers(users, query: 'SARA').single.name, 'sara@example.com');
    });
  });
}
