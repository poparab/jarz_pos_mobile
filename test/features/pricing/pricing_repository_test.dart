// ignore_for_file: overridden_fields

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/pricing/data/pricing_repository.dart';

import '../../helpers/mock_services.dart';

/// Minimal Dio stand-in that captures POST bodies and returns a canned
/// `{ "message": ... }` envelope (mirrors the pattern in b2b_customer_filter_test).
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
  group('PricingRepository reads', () {
    test('getPriceLists unwraps price_lists and parses categories', () async {
      final dio = _FakeDio()
        ..nextMessage = {
          'price_lists': [
            {
              'name': 'Companies',
              'currency': 'EGP',
              'customer_count': 3,
              'categories': [
                {'item_group': 'Medium', 'rate': 75, 'item_count': 10},
              ],
            },
          ],
        };
      final repo = PricingRepository(dio);

      final lists = await repo.getPriceLists();

      expect(dio.calls.single.path, ApiEndpoints.getPriceLists);
      expect(lists, hasLength(1));
      expect(lists.single.name, 'Companies');
      expect(lists.single.customerCount, 3);
      expect(lists.single.categories.single.rate, 75);
    });

    test('getPriceListDetail sends price_list and parses detail', () async {
      final dio = _FakeDio()
        ..nextMessage = {
          'name': 'Companies',
          'currency': 'EGP',
          'categories': [
            {'item_group': 'Medium', 'rate': 75, 'item_count': 10},
          ],
          'item_overrides': [
            {'item_code': 'CHOC-M', 'item_name': 'Choc', 'rate': 80},
          ],
          'customers': [
            {'customer': 'CUST-1', 'assignment': 'direct'},
          ],
        };
      final repo = PricingRepository(dio);

      final detail = await repo.getPriceListDetail('Companies');

      expect(dio.calls.single.path, ApiEndpoints.getPriceListDetail);
      expect((dio.calls.single.data as Map)['price_list'], 'Companies');
      expect(detail.itemOverrides.single.itemCode, 'CHOC-M');
      expect(detail.customers.single.customer, 'CUST-1');
    });

    test('getCustomerPricing sends customer and parses reverse view', () async {
      final dio = _FakeDio()
        ..nextMessage = {
          'customer': 'CUST-1',
          'assignment': 'direct',
          'effective_price_list': 'Companies',
          'prices': [
            {'item_group': 'Medium', 'rate': 82.5, 'source': 'override'},
          ],
        };
      final repo = PricingRepository(dio);

      final pricing = await repo.getCustomerPricing('CUST-1');

      expect(dio.calls.single.path, ApiEndpoints.getCustomerPricing);
      expect((dio.calls.single.data as Map)['customer'], 'CUST-1');
      expect(pricing.effectivePriceList, 'Companies');
      expect(pricing.prices.single.source, 'override');
    });

    test('searchB2bCustomers unwraps customers list', () async {
      final dio = _FakeDio()
        ..nextMessage = {
          'customers': [
            {'customer': 'CUST-1', 'customer_name': 'Acme'},
          ],
        };
      final repo = PricingRepository(dio);

      final results = await repo.searchB2bCustomers('Ac');

      expect(dio.calls.single.path, ApiEndpoints.searchB2bCustomers);
      expect((dio.calls.single.data as Map)['query'], 'Ac');
      expect(results.single.customer, 'CUST-1');
    });
  });

  group('PricingRepository writes', () {
    test('setCategoryPrice posts price_list, item_group and rate', () async {
      final dio = _FakeDio()..nextMessage = {'ok': true};
      final repo = PricingRepository(dio);

      await repo.setCategoryPrice(
        priceList: 'Companies',
        itemGroup: 'Medium',
        rate: 90,
      );

      final body = dio.calls.single.data as Map;
      expect(dio.calls.single.path, ApiEndpoints.setCategoryPrice);
      expect(body['price_list'], 'Companies');
      expect(body['item_group'], 'Medium');
      expect(body['rate'], 90);
    });

    test('setItemOverride with a rate upserts the override', () async {
      final dio = _FakeDio()..nextMessage = {'ok': true};
      final repo = PricingRepository(dio);

      await repo.setItemOverride(
        priceList: 'Companies',
        itemCode: 'CHOC-M',
        rate: 80,
      );

      final body = dio.calls.single.data as Map;
      expect(dio.calls.single.path, ApiEndpoints.setItemOverride);
      expect(body['item_code'], 'CHOC-M');
      expect(body['rate'], 80);
    });

    test('setItemOverride with null rate DELETES (sends rate: null)', () async {
      final dio = _FakeDio()..nextMessage = {'ok': true};
      final repo = PricingRepository(dio);

      await repo.setItemOverride(
        priceList: 'Companies',
        itemCode: 'CHOC-M',
        rate: null,
      );

      final body = dio.calls.single.data as Map;
      expect(body.containsKey('rate'), isTrue);
      expect(body['rate'], isNull);
    });

    test('assignCustomerToPriceList posts customer + price_list', () async {
      final dio = _FakeDio()..nextMessage = {'ok': true};
      final repo = PricingRepository(dio);

      await repo.assignCustomerToPriceList(
        customer: 'CUST-1',
        priceList: 'Companies',
      );

      final body = dio.calls.single.data as Map;
      expect(dio.calls.single.path, ApiEndpoints.assignCustomerToPriceList);
      expect(body['customer'], 'CUST-1');
      expect(body['price_list'], 'Companies');
    });

    test('createPriceList returns the created name', () async {
      final dio = _FakeDio()..nextMessage = {'name': 'Wholesale'};
      final repo = PricingRepository(dio);

      final name = await repo.createPriceList('Wholesale', currency: 'EGP');

      final body = dio.calls.single.data as Map;
      expect(dio.calls.single.path, ApiEndpoints.createPriceList);
      expect(body['price_list_name'], 'Wholesale');
      expect(body['currency'], 'EGP');
      expect(name, 'Wholesale');
    });
  });
}
