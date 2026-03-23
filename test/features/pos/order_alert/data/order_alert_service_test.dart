import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/pos/order_alert/data/order_alert_service.dart';

import '../../../../helpers/mock_services.dart';

/// Minimal Dio stand-in that captures requests and returns canned responses.
class _FakeDio with DioMixin implements Dio {
  final List<({String path, dynamic data})> calls = [];
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
    calls.add((path: path, data: data));
    if (nextError != null) {
      final err = nextError!;
      nextError = null;
      throw err;
    }
    final resp = nextResponse ?? Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: createSuccessResponse(data: {}),
    );
    nextResponse = null;
    return resp as Response<T>;
  }
}

void main() {
  late _FakeDio dio;
  late OrderAlertService service;

  setUp(() {
    dio = _FakeDio();
    service = OrderAlertService(dio);
  });

  // ── registerDevice ────────────────────────────────────────────────────

  group('registerDevice', () {
    test('posts to correct endpoint with all params', () async {
      await service.registerDevice(
        token: 'tok123',
        platform: 'android',
        deviceName: 'Pixel 7',
        appVersion: '1.0.0',
        posProfiles: ['Profile A', 'Profile B'],
      );

      expect(dio.calls, hasLength(1));
      expect(dio.calls.first.path, ApiEndpoints.registerMobileDevice);
      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload['token'], 'tok123');
      expect(payload['platform'], 'android');
      expect(payload['device_name'], 'Pixel 7');
      expect(payload['app_version'], '1.0.0');
      expect(payload['pos_profiles'], contains('Profile A'));
    });

    test('omits optional params when null', () async {
      await service.registerDevice(token: 'tok');

      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload.containsKey('platform'), isFalse);
      expect(payload.containsKey('device_name'), isFalse);
      expect(payload.containsKey('app_version'), isFalse);
      expect(payload.containsKey('pos_profiles'), isFalse);
    });

    test('omits pos_profiles when empty', () async {
      await service.registerDevice(token: 'tok', posProfiles: []);

      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload.containsKey('pos_profiles'), isFalse);
    });

    test('throws on network error', () async {
      dio.nextError = createMockDioException(message: 'timeout');
      expect(
        () => service.registerDevice(token: 'tok'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ── acknowledgeInvoice ────────────────────────────────────────────────

  group('acknowledgeInvoice', () {
    test('posts invoice_name to correct endpoint', () async {
      await service.acknowledgeInvoice('INV-001');

      expect(dio.calls, hasLength(1));
      expect(dio.calls.first.path, ApiEndpoints.acknowledgeInvoice);
      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload['invoice_name'], 'INV-001');
    });

    test('throws on error', () async {
      dio.nextError = createMockDioException(statusCode: 500);
      expect(
        () => service.acknowledgeInvoice('X'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ── getPendingAlerts ──────────────────────────────────────────────────

  group('getPendingAlerts', () {
    test('returns parsed alerts from response', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getPendingAlerts),
        statusCode: 200,
        data: {
          'message': {
            'alerts': [
              {
                'invoice_id': 'INV-A',
                'pos_profile': 'P',
                'grand_total': 100,
                'acceptance_status': 'Pending',
                'requires_acceptance': true,
              },
              {
                'invoice_id': 'INV-B',
                'pos_profile': 'P',
                'grand_total': 200,
              },
            ],
          },
        },
      );

      final alerts = await service.getPendingAlerts();
      expect(alerts, hasLength(2));
      expect(alerts[0].invoiceId, 'INV-A');
      expect(alerts[1].invoiceId, 'INV-B');
    });

    test('returns empty list when no alerts key', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getPendingAlerts),
        statusCode: 200,
        data: {'message': {}},
      );

      final alerts = await service.getPendingAlerts();
      expect(alerts, isEmpty);
    });

    test('returns empty list when message is not a Map', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getPendingAlerts),
        statusCode: 200,
        data: {'message': 'ok'},
      );

      final alerts = await service.getPendingAlerts();
      expect(alerts, isEmpty);
    });

    test('handles non-Map data in response', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getPendingAlerts),
        statusCode: 200,
        data: 'plain text',
      );

      final alerts = await service.getPendingAlerts();
      expect(alerts, isEmpty);
    });

    test('throws on network error', () async {
      dio.nextError = createMockDioException(message: 'fail');
      expect(
        () => service.getPendingAlerts(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
