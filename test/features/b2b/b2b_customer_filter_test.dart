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
  group('B2B existing-customer linking', () {
    test(
      'searchLinkableCustomers searches every enabled customer type',
      () async {
        final dio = _FakeDio();
        final repo = B2bRepository(dio);

        await repo.searchLinkableCustomers('ilo specialty coffee');

        final body = dio.calls.single.data as Map;
        expect(dio.calls.single.path, ApiEndpoints.b2bSearchLinkableCustomers);
        expect(body['query'], 'ilo specialty coffee');
        expect(body['limit'], 20);
        expect(body.containsKey('customer_type'), isFalse);
        expect(body.containsKey('customer_group'), isFalse);
      },
    );

    test('linkExistingCustomer sends optimistic link guard fields', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'success': true,
        'party_doctype': 'Lead',
        'party_name': 'LEAD-1',
        'customer': 'ilo specialty coffee',
        'changed': true,
        'linked_via': 'Lead',
      };
      final repo = B2bRepository(dio);

      final result = await repo.linkExistingCustomer(
        partyDoctype: 'Lead',
        partyName: 'LEAD-1',
        customer: 'ilo specialty coffee',
      );

      final body = dio.calls.single.data as Map;
      expect(dio.calls.single.path, ApiEndpoints.b2bLinkExistingCustomer);
      expect(body['party_doctype'], 'Lead');
      expect(body['party_name'], 'LEAD-1');
      expect(body['customer'], 'ilo specialty coffee');
      expect(body['allow_relink'], 0);
      expect(result['changed'], isTrue);
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

    test(
      'searchCustomers omits customer_type by default (back-compat)',
      () async {
        final dio = _FakeDio();
        final repo = PosRepository(dio);

        await repo.searchCustomers('Jane');

        final body = dio.calls.single.data as Map;
        expect(body.containsKey('customer_type'), isFalse);
        expect(body['name'], 'Jane');
      },
    );
  });
}
