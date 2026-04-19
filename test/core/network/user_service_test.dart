import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';

import '../../helpers/mock_services.dart';

/// Minimal Dio stand-in for UserService tests.
class _FakeDio with DioMixin implements Dio {
  Response? nextResponse;
  DioException? nextError;

  @override
  BaseOptions options = BaseOptions();

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (nextError != null) {
      final err = nextError!;
      nextError = null;
      throw err;
    }
    final resp = nextResponse!;
    nextResponse = null;
    return resp as Response<T>;
  }
}

void main() {
  // ── UserRoles model ───────────────────────────────────────────────────

  group('UserRoles.fromJson', () {
    test('parses all fields', () {
      final roles = UserRoles.fromJson({
        'user': 'admin@test.com',
        'full_name': 'Admin User',
        'roles': [RoleNames.jarzManager, RoleNames.moderator],
        'employee': 'EMP-001',
        'employee_name': 'Admin',
        'branch': 'Main',
        'require_pos_shift': true,
      });
      expect(roles.user, 'admin@test.com');
      expect(roles.fullName, 'Admin User');
      expect(roles.roles, hasLength(2));
      expect(roles.employee, 'EMP-001');
      expect(roles.branch, 'Main');
      expect(roles.requirePosShift, isTrue);
    });

    test('defaults for missing fields', () {
      final roles = UserRoles.fromJson({});
      expect(roles.user, '');
      expect(roles.fullName, isNull);
      expect(roles.roles, isEmpty);
      expect(roles.employee, isNull);
      expect(roles.branch, isNull);
      expect(roles.requirePosShift, isFalse);
    });

    test('require_pos_shift handles int 1', () {
      final roles = UserRoles.fromJson({'require_pos_shift': 1});
      expect(roles.requirePosShift, isTrue);
    });

    test('roles handles non-list value', () {
      final roles = UserRoles.fromJson({'roles': 'not a list'});
      expect(roles.roles, isEmpty);
    });
  });

  group('UserRoles getters', () {
    test('isJarzManager when role present', () {
      final r = UserRoles(user: 'u', roles: [RoleNames.jarzManager]);
      expect(r.isJarzManager, isTrue);
      expect(r.isManager, isTrue);
    });

    test('isLineManager', () {
      final r = UserRoles(user: 'u', roles: [RoleNames.jarzLineManager]);
      expect(r.isLineManager, isTrue);
      expect(r.canAccessManagerDashboard, isTrue);
    });

    test('isModerator', () {
      final r = UserRoles(user: 'u', roles: [RoleNames.moderator]);
      expect(r.isModerator, isTrue);
      expect(r.canAccessManagerDashboard, isFalse);
    });

    test('canMuteNotifications for managers', () {
      final r = UserRoles(user: 'u', roles: [RoleNames.jarzManager]);
      expect(r.canMuteNotifications, isTrue);
    });

    test('canMuteNotifications for line managers', () {
      final r = UserRoles(user: 'u', roles: [RoleNames.jarzLineManager]);
      expect(r.canMuteNotifications, isTrue);
    });

    test('canMuteNotifications for moderators', () {
      final r = UserRoles(user: 'u', roles: [RoleNames.moderator]);
      expect(r.canMuteNotifications, isTrue);
    });

    test('canMuteNotifications false for regular user', () {
      final r = UserRoles(user: 'u', roles: ['POS User']);
      expect(r.canMuteNotifications, isFalse);
    });

    test('all false when no roles', () {
      final r = UserRoles(user: 'u', roles: []);
      expect(r.isJarzManager, isFalse);
      expect(r.isLineManager, isFalse);
      expect(r.isModerator, isFalse);
      expect(r.canMuteNotifications, isFalse);
    });
  });

  // ── UserService ───────────────────────────────────────────────────────

  group('UserService.getCurrentUserRoles', () {
    late _FakeDio dio;
    late UserService service;

    setUp(() {
      dio = _FakeDio();
      service = UserService(dio);
    });

    test('parses from message envelope', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getCurrentUserRoles),
        statusCode: 200,
        data: {
          'message': {
            'user': 'user@test.com',
            'roles': ['POS User'],
            'branch': 'B1',
          },
        },
      );

      final roles = await service.getCurrentUserRoles();
      expect(roles.user, 'user@test.com');
      expect(roles.roles, ['POS User']);
      expect(roles.branch, 'B1');
    });

    test('parses from flat response (no message key)', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getCurrentUserRoles),
        statusCode: 200,
        data: {
          'user': 'direct@test.com',
          'roles': [],
        },
      );

      final roles = await service.getCurrentUserRoles();
      expect(roles.user, 'direct@test.com');
    });

    test('throws on unexpected data type', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getCurrentUserRoles),
        statusCode: 200,
        data: 'plain text',
      );

      expect(
        () => service.getCurrentUserRoles(),
        throwsA(isA<Exception>()),
      );
    });

    test('propagates DioException', () async {
      dio.nextError = createMockDioException(statusCode: 401);

      expect(
        () => service.getCurrentUserRoles(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
