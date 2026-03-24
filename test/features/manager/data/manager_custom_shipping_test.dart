import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manager/data/manager_api.dart';
import '../../../helpers/mock_services.dart';

class _FakeDioWithCalls with DioMixin implements Dio {
  final List<({String method, String path, dynamic data})> calls = [];
  Response? nextResponse;

  @override
  BaseOptions options = BaseOptions();

  Future<Response<T>> _handle<T>(String method, String path, {dynamic data}) async {
    calls.add((method: method, path: path, data: data));
    final resp = nextResponse ??
        Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: createSuccessResponse(data: {'success': true}),
        );
    nextResponse = null;
    return resp as Response<T>;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>('GET', path);

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>('POST', path, data: data);
}

void main() {
  group('ManagerApi Custom Shipping', () {
    late _FakeDioWithCalls dio;
    late ManagerApi api;

    setUp(() {
      dio = _FakeDioWithCalls();
      api = ManagerApi(dio);
    });

    test('getPendingCustomShippingRequests parses list', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.getPendingCustomShippingRequests),
        statusCode: 200,
        data: {
          'message': {
            'success': true,
            'data': [
              {
                'name': 'CSR-1',
                'invoice': 'SINV-1',
                'customer_name': 'Customer A',
                'territory': 'Main',
                'original_amount': 20,
                'requested_amount': 35,
                'reason': 'Far route',
                'requested_by': 'user@example.com',
                'requested_on': '2026-03-24 12:00:00',
              }
            ]
          }
        },
      );

      final rows = await api.getPendingCustomShippingRequests();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'CSR-1');
      expect(rows.first.requestedAmount, 35);
      expect(dio.calls.first.path, ApiEndpoints.getPendingCustomShippingRequests);
    });

    test('approveCustomShipping posts request_name', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.approveCustomShipping),
        statusCode: 200,
        data: {'message': {'success': true}},
      );

      await api.approveCustomShipping('CSR-55');
      expect(dio.calls.first.path, ApiEndpoints.approveCustomShipping);
      expect(dio.calls.first.data, {'request_name': 'CSR-55'});
    });

    test('rejectCustomShipping posts request_name with reason', () async {
      dio.nextResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.rejectCustomShipping),
        statusCode: 200,
        data: {'message': {'success': true}},
      );

      await api.rejectCustomShipping('CSR-77', reason: 'Unsupported amount');
      expect(dio.calls.first.path, ApiEndpoints.rejectCustomShipping);
      expect(dio.calls.first.data, {
        'request_name': 'CSR-77',
        'rejection_reason': 'Unsupported amount',
      });
    });
  });
}
