// User management repository wire shape: which method each call hits, GET vs
// POST, what it sends (only changed fields on update, role profiles as a JSON
// array), and that a server refusal propagates as a DioException.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/user_admin/data/user_admin_repository.dart';
import 'package:jarz_pos/src/features/user_admin/models/user_admin_models.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Object? Function(RequestOptions options) respond = (_) => const {};
  int statusCode = 200;

  /// When set, the whole body instead of the `{message: ...}` envelope.
  Map<String, dynamic>? rawBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(rawBody ?? {'message': respond(options)}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _base = '/api/method/jarz_pos.api.user_admin';

Map<String, dynamic> _user({String name = 'ali@example.com'}) => {
  'name': name,
  'email': name,
  'full_name': 'Ali',
  'enabled': 1,
  'role_profiles': ['Jarz Cashier'],
  'tier': 'staff',
  'can_edit': true,
};

void main() {
  late _Adapter adapter;
  late UserAdminRepository repository;

  setUp(() {
    adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    repository = UserAdminRepository(dio);
  });

  test('getContext is a GET and parses', () async {
    adapter.respond = (_) => {
      'can_manage': true,
      'is_system_manager': false,
      'min_password_length': 8,
      'role_profiles': [
        {
          'name': 'Jarz Cashier',
          'roles': ['POS User'],
          'tier': 'staff',
          'privileged': false,
          'assignable': true,
        },
      ],
    };
    final ctx = await repository.getContext();
    final request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(request.path, '$_base.get_context');
    expect(ctx.canManage, isTrue);
    expect(ctx.roleProfiles.single.assignable, isTrue);
  });

  test('listUsers sends search + include_disabled and parses rows', () async {
    adapter.respond = (_) => [
      _user(),
      _user(name: 'sara@example.com'),
      {'full_name': 'no name - dropped'},
    ];
    final users = await repository.listUsers(search: '  ali ');
    final request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(request.path, '$_base.list_users');
    expect(request.queryParameters, {'search': 'ali', 'include_disabled': 1});
    expect(users.map((u) => u.name), ['ali@example.com', 'sara@example.com']);
  });

  test('listUsers without search omits it', () async {
    adapter.respond = (_) => const [];
    await repository.listUsers(includeDisabled: false);
    expect(adapter.requests.single.queryParameters, {'include_disabled': 0});
  });

  test('a non-list answer reads as no users', () async {
    adapter.respond = (_) => {'unexpected': true};
    expect(await repository.listUsers(), isEmpty);
  });

  test('getUser passes the user', () async {
    adapter.respond = (_) => _user();
    final u = await repository.getUser('ali@example.com');
    final request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(request.path, '$_base.get_user');
    expect(request.queryParameters, {'user': 'ali@example.com'});
    expect(u.displayName, 'Ali');
  });

  test('listEmployees parses user_id links', () async {
    adapter.respond = (_) => [
      {
        'name': 'HR-EMP-1',
        'employee_name': 'Mona',
        'branch': 'Dokki',
        'user_id': 'mona@example.com',
      },
      {'name': 'HR-EMP-2', 'employee_name': 'Omar', 'user_id': null},
    ];
    final employees = await repository.listEmployees(search: 'mo');
    final request = adapter.requests.single;
    expect(request.path, '$_base.list_employees');
    expect(request.queryParameters, {'search': 'mo'});
    expect(employees.first.userId, 'mona@example.com');
    expect(employees.last.userId, isNull);
  });

  test('createUser posts role_profiles as a JSON array', () async {
    adapter.respond = (_) => _user(name: 'new@example.com');
    final created = await repository.createUser(
      email: ' new@example.com ',
      firstName: 'New',
      password: 'secret123',
      roleProfiles: const ['Jarz Cashier', 'Jarz Moderator'],
      lastName: '',
      mobileNo: '0100',
      requirePosShift: true,
      employee: 'HR-EMP-9',
    );
    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '$_base.create_user');
    expect(request.data, {
      'email': 'new@example.com',
      'first_name': 'New',
      'password': 'secret123',
      'role_profiles': '["Jarz Cashier","Jarz Moderator"]',
      'mobile_no': '0100',
      'require_pos_shift': 1,
      'employee': 'HR-EMP-9',
    });
    expect(created.name, 'new@example.com');
  });

  test('updateUser sends only what changed', () async {
    adapter.respond = (_) => _user();
    await repository.updateUser(user: 'ali@example.com', lastName: '');
    expect(adapter.requests.single.path, '$_base.update_user');
    expect(adapter.requests.single.data, {
      'user': 'ali@example.com',
      'last_name': '',
    });
  });

  test('updateUser: role profiles, shift flag and unlink', () async {
    adapter.respond = (_) => _user();
    await repository.updateUser(
      user: 'ali@example.com',
      roleProfiles: const ['Jarz Manager'],
      requirePosShift: false,
      clearEmployee: true,
    );
    expect(adapter.requests.single.data, {
      'user': 'ali@example.com',
      'role_profiles': '["Jarz Manager"]',
      'require_pos_shift': 0,
      'clear_employee': 1,
    });
  });

  test('setEnabled posts 0/1', () async {
    adapter.respond = (_) => {..._user(), 'enabled': 0};
    final u = await repository.setEnabled(
      user: 'ali@example.com',
      enabled: false,
    );
    expect(adapter.requests.single.path, '$_base.set_enabled');
    expect(adapter.requests.single.data, {
      'user': 'ali@example.com',
      'enabled': 0,
    });
    expect(u.enabled, isFalse);
  });

  test('resetPassword posts the password and sign_out', () async {
    adapter.respond = (_) => {'ok': true, 'user': 'ali@example.com'};
    final ack = await repository.resetPassword(
      user: 'ali@example.com',
      newPassword: 'n3wpassword',
      signOut: false,
    );
    expect(adapter.requests.single.path, '$_base.reset_password');
    expect(adapter.requests.single.data, {
      'user': 'ali@example.com',
      'new_password': 'n3wpassword',
      'sign_out': 0,
    });
    expect(ack.ok, isTrue);
  });

  test('deleteUser posts the user and parses deleted', () async {
    adapter.respond = (_) => {'ok': true, 'deleted': 'ali@example.com'};
    final ack = await repository.deleteUser('ali@example.com');
    expect(adapter.requests.single.path, '$_base.delete_user');
    expect(adapter.requests.single.data, {'user': 'ali@example.com'});
    expect(ack.user, 'ali@example.com');
  });

  test('a refusal propagates as a DioException with the body', () async {
    adapter.statusCode = 417;
    adapter.rawBody = {
      'exc_type': 'LinkExistsError',
      '_server_messages': jsonEncode([
        jsonEncode({'message': 'Linked to 3 Sales Invoices. Disable instead.'}),
      ]),
    };
    await expectLater(
      repository.deleteUser('ali@example.com'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          417,
        ),
      ),
    );
  });

  test('UserAdminUser survives the envelope missing', () async {
    adapter.rawBody = _user();
    final u = await repository.getUser('ali@example.com');
    expect(u, isA<UserAdminUser>());
    expect(u.name, 'ali@example.com');
  });
}
