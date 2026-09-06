import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/repositories/customer_address_repository.dart';

class _FakeDio with DioMixin implements Dio {
  dynamic sentData;
  BaseOptions _testOptions = BaseOptions();

  @override
  BaseOptions get options => _testOptions;

  @override
  set options(BaseOptions value) => _testOptions = value;

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
    expect(path, ApiEndpoints.saveCustomerShippingAddress);
    sentData = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data:
          {
                'message': {
                  'success': true,
                  'selected_address_name': 'ILO-MADINATY',
                  'address_book': {
                    'selected_address_name': 'ILO-MADINATY',
                    'branch_options': [
                      {
                        'address_name': 'ILO-MADINATY',
                        'branch_name': 'All Seasons Park',
                        'effective_territory': 'EGMADINATY',
                      },
                    ],
                  },
                },
              }
              as T,
    );
  }
}

void main() {
  test('B2B branch save names Address without changing primary', () async {
    final dio = _FakeDio();
    final repository = CustomerAddressRepository(dio);

    final result = await repository.saveAddress(
      customer: 'ilo specialty coffee',
      phone: '01000000000',
      branchName: 'All Seasons Park',
      address: 'Madinaty All Seasons Park',
      territory: 'EGMADINATY',
      setAsPrimary: false,
    );

    final body = dio.sentData as Map;
    expect(body['branch_name'], 'All Seasons Park');
    expect(body['territory'], 'EGMADINATY');
    expect(body['set_as_primary'], 0);
    expect(result['selected_address_name'], 'ILO-MADINATY');
  });
}
