// Courier setup: JSON parsing, repository wire shape, the one-time PIN rules
// (never in toString) and the WhatsApp invite text.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/user_admin/data/courier_invite_text.dart';
import 'package:jarz_pos/src/features/user_admin/data/courier_setup_repository.dart';
import 'package:jarz_pos/src/features/user_admin/models/courier_setup_models.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Object? Function(RequestOptions options) respond = (_) => const {};
  int statusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'message': respond(options)}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _setupJson = {
  'user': 'ali@example.com',
  'employee': 'HR-EMP-7',
  'login_id': '01012345678',
  'pin': '482913',
  'diagnosis': {
    'ok': false,
    'user': 'ali@example.com',
    'display_name': 'Ali',
    'problems': ['no_pos_profile', 'weird_new_code'],
    'message': 'Not on a POS Profile',
  },
  'links': {
    'web_url': 'https://erp.example.com/courier',
    'apk_url': 'https://erp.example.com/courier.apk',
  },
};

void main() {
  group('CourierCandidates.fromJson', () {
    test('parses employees and string branches', () {
      final c = CourierCandidates.fromJson({
        'employees': [
          {
            'employee': 'HR-EMP-1',
            'employee_name': 'Mostafa',
            'branch': 'Maadi',
            'user': 'm@example.com',
            'is_courier': 1,
            'setup_ok': true,
            'problems': [],
          },
          {
            'employee': 'HR-EMP-2',
            'employee_name': '',
            'is_courier': 0,
            'setup_ok': 0,
            'problems': ['no_identity'],
          },
        ],
        'branches': ['Maadi', 'Nasr City', 'Maadi'],
      });
      expect(c.employees, hasLength(2));
      final a = c.employees.first;
      expect(a.displayName, 'Mostafa');
      expect(a.isCourier, isTrue);
      expect(a.setupOk, isTrue);
      expect(a.hasUser, isTrue);
      final b = c.employees.last;
      expect(b.displayName, 'HR-EMP-2');
      expect(b.hasUser, isFalse);
      expect(b.problems, ['no_identity']);
      expect(c.branches, ['Maadi', 'Nasr City']);
    });

    test('accepts branches as maps and skips blanks', () {
      final c = CourierCandidates.fromJson({
        'employees': [],
        'branches': [
          {'name': 'Maadi'},
          {'branch': 'Zayed'},
          '',
          null,
        ],
      });
      expect(c.branches, ['Maadi', 'Zayed']);
    });

    test('a malformed body is empty, not an error', () {
      final c = CourierCandidates.fromJson({'employees': 'x'});
      expect(c.employees, isEmpty);
      expect(c.branches, isEmpty);
    });

    test('matches searches id, name, branch and login', () {
      const c = CourierCandidate(
        employee: 'HR-EMP-1',
        employeeName: 'Mostafa Ali',
        branch: 'Maadi',
        user: 'm@example.com',
      );
      expect(c.matches(''), isTrue);
      expect(c.matches('mostafa'), isTrue);
      expect(c.matches('MAADI'), isTrue);
      expect(c.matches('m@exa'), isTrue);
      expect(c.matches('zayed'), isFalse);
    });
  });

  group('CourierSetupResult', () {
    test('parses login, pin, diagnosis and links', () {
      final r = CourierSetupResult.fromJson(_setupJson);
      expect(r.user, 'ali@example.com');
      expect(r.employee, 'HR-EMP-7');
      expect(r.signInId, '01012345678');
      expect(r.pin, '482913');
      expect(r.diagnosis.ok, isFalse);
      expect(r.diagnosis.displayName, 'Ali');
      expect(r.diagnosis.problems, ['no_pos_profile', 'weird_new_code']);
      expect(r.links.webUrl, 'https://erp.example.com/courier');
      expect(r.links.apkUrl, 'https://erp.example.com/courier.apk');
    });

    test('signInId falls back to the user when there is no login id', () {
      final r = CourierSetupResult.fromJson({'user': 'a@b.c', 'pin': '123456'});
      expect(r.signInId, 'a@b.c');
      expect(r.links.webUrl, isNull);
      expect(r.diagnosis.problems, isEmpty);
    });

    test('the PIN never appears in toString', () {
      final r = CourierSetupResult.fromJson(_setupJson);
      expect(r.toString(), isNot(contains('482913')));
      final reset = CourierPinReset.fromJson({
        'user': 'a@b.c',
        'login_id': '0101',
        'pin': '654321',
      });
      expect(reset.signInId, '0101');
      expect(reset.pin, '654321');
      expect(reset.toString(), isNot(contains('654321')));
    });
  });

  group('CourierSetupRepository', () {
    late _Adapter adapter;
    late CourierSetupRepository repository;

    setUp(() {
      adapter = _Adapter();
      repository = CourierSetupRepository(Dio()..httpClientAdapter = adapter);
    });

    test('listCandidates POSTs to the candidates endpoint', () async {
      adapter.respond = (_) => {'employees': [], 'branches': ['Maadi']};
      final c = await repository.listCandidates();
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, ApiEndpoints.courierListCandidates);
      expect(c.branches, ['Maadi']);
    });

    test('setupCourier sends only non-blank, trimmed fields', () async {
      adapter.respond = (_) => _setupJson;
      final r = await repository.setupCourier(
        fullName: '  Ali  ',
        mobileNo: '01012345678',
        branch: 'Maadi',
        posProfile: '   ',
      );
      final req = adapter.requests.single;
      expect(req.path, ApiEndpoints.courierSetup);
      expect(req.data, {
        'full_name': 'Ali',
        'mobile_no': '01012345678',
        'branch': 'Maadi',
      });
      expect(r.pin, '482913');
    });

    test('setupCourier for an existing employee sends the id', () async {
      adapter.respond = (_) => _setupJson;
      await repository.setupCourier(employee: 'HR-EMP-7', branch: 'Maadi');
      expect(adapter.requests.single.data, {
        'employee': 'HR-EMP-7',
        'branch': 'Maadi',
      });
    });

    test('resetPin and getSetup send the user', () async {
      adapter.respond = (o) => o.path == ApiEndpoints.courierResetPin
          ? {'user': 'a@b.c', 'login_id': '0101', 'pin': '111222'}
          : {'ok': true, 'problems': []};
      final reset = await repository.resetPin('a@b.c');
      final diag = await repository.getSetup('a@b.c');
      expect(adapter.requests[0].data, {'user': 'a@b.c'});
      expect(adapter.requests[1].path, ApiEndpoints.courierGetSetup);
      expect(adapter.requests[1].data, {'user': 'a@b.c'});
      expect(reset.pin, '111222');
      expect(diag.ok, isTrue);
    });

    test('isAvailable is true on success and false on any failure', () async {
      adapter.respond = (_) => {'employees': [], 'branches': []};
      expect(await repository.isAvailable(), isTrue);
      adapter.statusCode = 404;
      expect(await repository.isAvailable(), isFalse);
    });
  });

  group('buildCourierInviteText', () {
    test('contains the login, PIN and both links', () {
      final t = buildCourierInviteText(
        signInId: '0101',
        pin: '482913',
        displayName: 'Ali',
        webUrl: 'https://w.example/c',
        apkUrl: 'https://w.example/c.apk',
      );
      expect(t, contains('*0101*'));
      expect(t, contains('*482913*'));
      expect(t, contains('https://w.example/c'));
      expect(t, contains('https://w.example/c.apk'));
      expect(t, contains('Ali'));
    });

    test('omits link lines when there are none and varies on reset', () {
      final fresh = buildCourierInviteText(signInId: '0101', pin: '123456');
      final reset = buildCourierInviteText(
        signInId: '0101',
        pin: '123456',
        isReset: true,
      );
      expect(fresh, isNot(contains('http')));
      expect(fresh, isNot(equals(reset)));
    });
  });
}
