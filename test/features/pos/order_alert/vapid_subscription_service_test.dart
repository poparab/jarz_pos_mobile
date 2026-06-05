// ignore_for_file: overridden_fields
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/pos/order_alert/data/order_alert_service.dart';
import 'package:jarz_pos/src/features/pos/order_alert/vapid_subscription_service.dart';

import '../../../helpers/mock_services.dart';

/// Minimal Dio stub that captures requests and returns canned responses.
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
    final resp = nextResponse ??
        Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: createSuccessResponse(data: {}),
        );
    nextResponse = null;
    return resp as Response<T>;
  }
}

void main() {
  // ── VapidSubscriptionResult model ─────────────────────────────────────────

  group('VapidSubscriptionResult', () {
    test('isSuccess returns true only for subscribed status', () {
      const success = VapidSubscriptionResult(
        status: VapidSubscriptionStatus.subscribed,
        message: 'OK',
        subscriptionJson: '{}',
      );
      const failed = VapidSubscriptionResult(
        status: VapidSubscriptionStatus.failed,
        message: 'error',
      );
      const unsupported = VapidSubscriptionResult(
        status: VapidSubscriptionStatus.unsupported,
        message: 'unsupported',
      );

      expect(success.isSuccess, isTrue);
      expect(failed.isSuccess, isFalse);
      expect(unsupported.isSuccess, isFalse);
    });

    test('subscriptionJson is accessible on success', () {
      const result = VapidSubscriptionResult(
        status: VapidSubscriptionStatus.subscribed,
        message: 'OK',
        subscriptionJson: '{"endpoint":"https://example.com"}',
      );
      expect(result.subscriptionJson, '{"endpoint":"https://example.com"}');
    });

    test('browser hint is passed through', () {
      const result = VapidSubscriptionResult(
        status: VapidSubscriptionStatus.subscribed,
        message: 'OK',
        subscriptionJson: '{}',
        browser: 'Safari/iOS',
      );
      expect(result.browser, 'Safari/iOS');
    });
  });

  // ── VapidSubscriptionService stub (non-web platforms) ─────────────────────

  group('VapidSubscriptionService stub', () {
    test('requestSubscription returns unsupported on non-web', () async {
      // On the Dart VM (non-web), the stub is compiled in.
      // The stub must accept an OrderAlertService but always returns unsupported.
      final fakeDio = _FakeDio();
      final service = OrderAlertService(fakeDio);

      final result = await VapidSubscriptionService.requestSubscription(
        service: service,
      );

      expect(result.status, VapidSubscriptionStatus.unsupported);
      expect(result.isSuccess, isFalse);
    });

    test('subscribeIfPermissionGranted returns unsupported on non-web', () async {
      final fakeDio = _FakeDio();
      final service = OrderAlertService(fakeDio);

      final result = await VapidSubscriptionService.subscribeIfPermissionGranted(
        service: service,
      );

      expect(result.status, VapidSubscriptionStatus.unsupported);
    });
  });

  // ── OrderAlertService VAPID methods ───────────────────────────────────────

  group('OrderAlertService.fetchVapidPublicKey', () {
    late _FakeDio dio;
    late OrderAlertService service;

    setUp(() {
      dio = _FakeDio();
      service = OrderAlertService(dio);
    });

    test('posts to getVapidPublicKey endpoint and returns public key', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getVapidPublicKey),
        statusCode: 200,
        data: createSuccessResponse(data: {'public_key': 'BTestPublicKey123'}),
      );

      final key = await service.fetchVapidPublicKey();

      expect(dio.calls.length, 1);
      expect(dio.calls.first.path, ApiEndpoints.getVapidPublicKey);
      expect(key, 'BTestPublicKey123');
    });

    test('throws if public_key missing from response', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getVapidPublicKey),
        statusCode: 200,
        data: createSuccessResponse(data: {}),
      );

      expect(
        () => service.fetchVapidPublicKey(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OrderAlertService.registerVapidSubscription', () {
    late _FakeDio dio;
    late OrderAlertService service;

    setUp(() {
      dio = _FakeDio();
      service = OrderAlertService(dio);
    });

    test('posts to registerVapidSubscription with subscription_json', () async {
      const subJson = '{"endpoint":"https://web.push.apple.com/test","keys":{"p256dh":"k","auth":"a"}}';

      await service.registerVapidSubscription(subscriptionJson: subJson);

      expect(dio.calls.length, 1);
      expect(dio.calls.first.path, ApiEndpoints.registerVapidSubscription);
      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload['subscription_json'], subJson);
    });

    test('includes browser hint when provided', () async {
      await service.registerVapidSubscription(
        subscriptionJson: '{"endpoint":"https://ep","keys":{"p256dh":"k","auth":"a"}}',
        browser: 'Safari/iOS',
      );

      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload['browser'], 'Safari/iOS');
    });

    test('omits browser key when null', () async {
      await service.registerVapidSubscription(
        subscriptionJson: '{"endpoint":"https://ep","keys":{"p256dh":"k","auth":"a"}}',
      );

      final payload = dio.calls.first.data as Map<String, dynamic>;
      expect(payload.containsKey('browser'), isFalse);
    });
  });

  // ── Base64url decode logic (mirrors _base64UrlDecode in web service) ────────

  group('base64url decode logic', () {
    // These tests specify the transformation used in vapid_subscription_service_web.dart.

    Uint8List decodeBase64Url(String input) {
      String padded = input.replaceAll('-', '+').replaceAll('_', '/');
      final remainder = padded.length % 4;
      if (remainder == 2) {
        padded += '==';
      } else if (remainder == 3) {
        padded += '=';
      }
      return base64Decode(padded);
    }

    test('round-trips a 65-byte uncompressed EC public key', () {
      // Build a synthetic 65-byte blob (0x04 prefix = uncompressed EC point)
      final original = Uint8List(65);
      original[0] = 0x04;
      for (var i = 1; i < 65; i++) original[i] = i & 0xFF;

      // Encode with Dart's base64Url codec (produces '-' and '_', no padding)
      final b64url = base64Url.encode(original).replaceAll('=', '');
      expect(b64url.length, 87); // 65 bytes → 87 url-safe chars, no padding

      // Decode back using the service logic
      final decoded = decodeBase64Url(b64url);
      expect(decoded.length, 65);
      expect(decoded[0], 0x04);
      expect(decoded, equals(original));
    });

    test('handles url-safe chars (- and _) that arise from real keys', () {
      // Generate bytes that produce '-' and '_' when base64url-encoded.
      // 0xFB in a 3-byte group always produces at least one '-' in base64url.
      final bytes = Uint8List.fromList([0xFB, 0xEF, 0xBE, 0xFF]);
      final b64url = base64Url.encode(bytes).replaceAll('=', '');
      // Verify the encoded string actually contains url-safe chars
      expect(b64url.contains('-') || b64url.contains('_'), isTrue);

      // Must decode back to original bytes
      final decoded = decodeBase64Url(b64url);
      expect(decoded, equals(bytes));
    });

    test('handles already-padded base64', () {
      const b64url = 'dGVzdA==';
      final bytes = decodeBase64Url(b64url);
      expect(utf8.decode(bytes), 'test');
    });
  });
}
