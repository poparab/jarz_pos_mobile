// ignore_for_file: overridden_fields

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';

import '../../helpers/mock_services.dart';

/// Minimal Dio stand-in that captures POST bodies and returns canned data.
class _FakeDio with DioMixin implements Dio {
  final List<({String path, dynamic data})> calls = [];
  dynamic nextMessage = const <dynamic>[];

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
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: createSuccessResponse(data: nextMessage) as T,
    );
  }
}

void main() {
  group('B2B search uses Company filter', () {
    test('searchCompanyCustomers sends customer_type=Company (name)', () async {
      final dio = _FakeDio();
      final repo = B2bRepository(dio);

      await repo.searchCompanyCustomers('Acme');

      final body = dio.calls.single.data as Map;
      expect(dio.calls.single.path, ApiEndpoints.searchCustomers);
      expect(body['customer_type'], 'Company');
      expect(body['name'], 'Acme');
      expect(body.containsKey('phone'), isFalse);
    });

    test('searchCompanyCustomers uses phone key for numeric queries', () async {
      final dio = _FakeDio();
      final repo = B2bRepository(dio);

      await repo.searchCompanyCustomers('0101234567');

      final body = dio.calls.single.data as Map;
      expect(body['customer_type'], 'Company');
      expect(body['phone'], '0101234567');
      expect(body.containsKey('name'), isFalse);
    });
  });

  group('POS search uses Individual filter when requested', () {
    test('searchCustomers forwards customer_type when provided', () async {
      final dio = _FakeDio();
      final repo = PosRepository(dio);

      await repo.searchCustomers('Jane', customerType: 'Individual');

      final body = dio.calls.single.data as Map;
      expect(body['customer_type'], 'Individual');
      expect(body['name'], 'Jane');
    });

    test('searchCustomers omits customer_type by default (back-compat)',
        () async {
      final dio = _FakeDio();
      final repo = PosRepository(dio);

      await repo.searchCustomers('Jane');

      final body = dio.calls.single.data as Map;
      expect(body.containsKey('customer_type'), isFalse);
      expect(body['name'], 'Jane');
    });
  });
}
