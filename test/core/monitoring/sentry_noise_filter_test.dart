import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:jarz_pos/src/core/monitoring/sentry_service.dart';

SentryEvent _eventFor(Object throwable) => SentryEvent(throwable: throwable);

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  String? message,
}) {
  final requestOptions = RequestOptions(path: '/api/method/ping');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    message: message,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
          ),
  );
}

void main() {
  group('SentryNoiseFilter drops expected connectivity noise', () {
    for (final type in const <DioExceptionType>[
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('should drop DioException of type ${type.name}', () {
        expect(SentryNoiseFilter.isNoise(_eventFor(_dioError(type))), isTrue);
      });
    }

    test('should drop the offline poll failure that dominates the quota', () {
      // JARZ-FLUTTER-CLIENT-D: 5673 events of syncPendingAlerts polling offline.
      final event = _eventFor(
        Exception('Failed host lookup: erpstg.orderjarz.com'),
      );

      expect(SentryNoiseFilter.isNoise(event), isTrue);
    });

    test('should drop SocketException and web XMLHttpRequest failures', () {
      expect(
        SentryNoiseFilter.isNoise(
          _eventFor(Exception('SocketException: Connection refused')),
        ),
        isTrue,
      );
      expect(
        SentryNoiseFilter.isNoise(
          _eventFor(Exception('XMLHttpRequest error.')),
        ),
        isTrue,
      );
    });

    test('should drop "Cannot reach server" wrappers', () {
      expect(
        SentryNoiseFilter.isNoise(_eventFor(Exception('Cannot reach server'))),
        isTrue,
      );
    });

    test('should drop invalid credentials, since a typo is not a bug', () {
      expect(
        SentryNoiseFilter.isNoise(_eventFor(Exception('Invalid credentials'))),
        isTrue,
      );
    });

    test('should match noise regardless of casing', () {
      expect(
        SentryNoiseFilter.isNoise(_eventFor(Exception('FAILED HOST LOOKUP'))),
        isTrue,
      );
    });

    test('should drop noise carried on the event message', () {
      final event = SentryEvent(
        message: SentryMessage('Failed host lookup: erpstg.orderjarz.com'),
      );

      expect(SentryNoiseFilter.isNoise(event), isTrue);
    });
  });

  group('SentryNoiseFilter keeps actionable events', () {
    test('should keep genuine server errors returned as badResponse', () {
      for (final statusCode in const <int>[400, 401, 403, 404, 417, 500, 502]) {
        final event = _eventFor(
          _dioError(DioExceptionType.badResponse, statusCode: statusCode),
        );

        expect(
          SentryNoiseFilter.isNoise(event),
          isFalse,
          reason: 'HTTP $statusCode is a real server fault and must be kept',
        );
      }
    });

    test('should keep a badResponse even when its body mentions a socket', () {
      // Over-filtering would hide real backend faults: the type wins.
      final event = _eventFor(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 500,
          message: 'SocketException on the server side',
        ),
      );

      expect(SentryNoiseFilter.isNoise(event), isFalse);
    });

    test('should keep ordinary application errors', () {
      expect(
        SentryNoiseFilter.isNoise(
          _eventFor(StateError('Cannot use ref after the widget was disposed')),
        ),
        isFalse,
      );
      expect(
        SentryNoiseFilter.isNoise(
          _eventFor(TypeError()),
        ),
        isFalse,
      );
    });

    test('should keep events with no throwable or message', () {
      expect(SentryNoiseFilter.isNoise(SentryEvent()), isFalse);
    });
  });
}
