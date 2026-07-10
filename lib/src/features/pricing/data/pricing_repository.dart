import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/pricing_models.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PricingRepository(dio);
});

/// HTTP repository for the Price Lists feature (`jarz_pos.api.price_lists.*`).
///
/// Reads are allowed for managers + B2B sales reps; writes are managers only
/// (the backend raises `frappe.PermissionError` otherwise). The UI gates the
/// write controls up front, but the server is the source of truth.
class PricingRepository {
  final Dio _dio;
  PricingRepository(this._dio);

  /// Unwraps Frappe's `{ "message": ... }` envelope.
  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'];
    }
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  List<Map<String, dynamic>> _asMapList(dynamic value) =>
      (value as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  // ── Reads (managers + B2B reps) ───────────────────────────────────────

  Future<List<PriceListSummary>> getPriceLists() async {
    final response = await _dio.post(ApiEndpoints.getPriceLists, data: {});
    final payload = _asMap(_unwrap(response));
    return _asMapList(payload['price_lists'])
        .map(PriceListSummary.fromJson)
        .toList();
  }

  Future<PriceListDetail> getPriceListDetail(String priceList) async {
    final response = await _dio.post(
      ApiEndpoints.getPriceListDetail,
      data: {'price_list': priceList},
    );
    return PriceListDetail.fromJson(_asMap(_unwrap(response)));
  }

  Future<CustomerPricing> getCustomerPricing(String customer) async {
    final response = await _dio.post(
      ApiEndpoints.getCustomerPricing,
      data: {'customer': customer},
    );
    return CustomerPricing.fromJson(_asMap(_unwrap(response)));
  }

  Future<List<PricingCategory>> listPricingCategories() async {
    final response = await _dio.post(
      ApiEndpoints.listPricingCategories,
      data: {},
    );
    final payload = _asMap(_unwrap(response));
    return _asMapList(payload['categories'])
        .map(PricingCategory.fromJson)
        .toList();
  }

  Future<List<B2bCustomerResult>> searchB2bCustomers([String query = '']) async {
    final response = await _dio.post(
      ApiEndpoints.searchB2bCustomers,
      data: {'query': query},
    );
    final payload = _asMap(_unwrap(response));
    return _asMapList(payload['customers'])
        .map(B2bCustomerResult.fromJson)
        .toList();
  }

  // ── Writes (managers only) ────────────────────────────────────────────

  /// Creates a selling price list. Returns its `name`.
  Future<String> createPriceList(
    String priceListName, {
    String currency = 'EGP',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createPriceList,
      data: {'price_list_name': priceListName, 'currency': currency},
    );
    final payload = _asMap(_unwrap(response));
    return (payload['name'] ?? priceListName).toString();
  }

  /// Upserts the item-group (category) rate for a price list.
  Future<void> setCategoryPrice({
    required String priceList,
    required String itemGroup,
    required num rate,
  }) async {
    await _dio.post(
      ApiEndpoints.setCategoryPrice,
      data: {
        'price_list': priceList,
        'item_group': itemGroup,
        'rate': rate,
      },
    );
  }

  /// Upserts a per-item override. Passing [rate] == null DELETES the override.
  Future<void> setItemOverride({
    required String priceList,
    required String itemCode,
    num? rate,
  }) async {
    await _dio.post(
      ApiEndpoints.setItemOverride,
      data: {
        'price_list': priceList,
        'item_code': itemCode,
        'rate': rate,
      },
    );
  }

  /// Assigns [customer] to [priceList]. Passing null clears the direct
  /// assignment (reverts to the customer group's default).
  Future<void> assignCustomerToPriceList({
    required String customer,
    String? priceList,
  }) async {
    await _dio.post(
      ApiEndpoints.assignCustomerToPriceList,
      data: {
        'customer': customer,
        'price_list': priceList,
      },
    );
  }
}
